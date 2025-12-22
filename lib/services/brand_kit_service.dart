import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/brand_kit_model.dart';
import 'http_service.dart';
import 'advanced_ai_content_service.dart';

/// خدمة إدارة Brand Kit مع تحليل الترندات
class BrandKitService extends GetxService {
  HttpService? _httpService;
  AdvancedAIContentService? _aiService;

  final RxList<BrandKit> brandKits = <BrandKit>[].obs;
  final Rx<BrandKit?> activeBrandKit = Rx<BrandKit?>(null);
  final RxList<TrendingIdea> trendingIdeas = <TrendingIdea>[].obs;
  final RxList<BrandSuggestion> suggestions = <BrandSuggestion>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAnalyzing = false.obs;

  Box<BrandKit>? _brandBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    print('🎨 Brand Kit Service initialized');
    _initServices();
    await _initHive();
    await loadBrandKits();
  }

  void _initServices() {
    try {
      if (Get.isRegistered<HttpService>()) {
        _httpService = Get.find<HttpService>();
      }
      if (Get.isRegistered<AdvancedAIContentService>()) {
        _aiService = Get.find<AdvancedAIContentService>();
      }
    } catch (e) {
      print('⚠️ Some services not available for BrandKitService: $e');
    }
  }

  Future<void> _initHive() async {
    try {
      _brandBox = await Hive.openBox<BrandKit>('brand_kits');
      print('✅ Brand Kits Hive box opened');
    } catch (e) {
      print('❌ Error opening brand kits box: $e');
      _brandBox = null;
    }
  }

  // ==================== CRUD Operations ====================

  /// حفظ Brand Kit جديد
  Future<bool> saveBrandKit(BrandKit brandKit) async {
    try {
      isLoading.value = true;

      // حفظ محلياً أولاً (دائماً)
      if (_brandBox != null) {
        await _brandBox!.put(brandKit.id, brandKit);
        print('✅ Brand Kit saved locally');
      }

      // إضافة للقائمة
      final existingIndex = brandKits.indexWhere((b) => b.id == brandKit.id);
      if (existingIndex != -1) {
        brandKits[existingIndex] = brandKit;
      } else {
        brandKits.add(brandKit);
      }

      if (brandKit.isActive) {
        activeBrandKit.value = brandKit;
      }

      // محاولة المزامنة مع السيرفر (غير مطلوبة للنجاح)
      if (_httpService != null) {
        try {
          final response = await _httpService!.post(
            '/brand-kits',
            body: brandKit.toJson(),
          );

          if (response['success'] == true) {
            print('✅ Brand Kit synced with server');
          }
        } catch (e) {
          print('⚠️ Server sync failed (saved locally): $e');
        }
      }

      print('✅ Brand Kit saved successfully');
      return true;
    } catch (e) {
      print('❌ Error saving brand kit: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث Brand Kit
  Future<bool> updateBrandKit(BrandKit brandKit) async {
    try {
      isLoading.value = true;

      brandKit.updatedAt = DateTime.now();

      // حفظ محلياً أولاً
      if (_brandBox != null) {
        await _brandBox!.put(brandKit.id, brandKit);
      }

      final index = brandKits.indexWhere((b) => b.id == brandKit.id);
      if (index != -1) {
        brandKits[index] = brandKit;
      }

      if (activeBrandKit.value?.id == brandKit.id) {
        activeBrandKit.value = brandKit;
      }

      // محاولة المزامنة مع السيرفر
      if (_httpService != null) {
        try {
          final response = await _httpService!.put(
            '/brand-kits/${brandKit.id}',
            body: brandKit.toJson(),
          );

          if (response['success'] == true) {
            print('✅ Brand Kit synced with server');
          }
        } catch (e) {
          print('⚠️ Failed to sync with server, saved locally: $e');
        }
      }

      print('✅ Brand Kit updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating brand kit: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل جميع Brand Kits
  Future<void> loadBrandKits() async {
    try {
      isLoading.value = true;

      // محاولة التحميل من Backend
      if (_httpService != null) {
        try {
          final response = await _httpService!.get('/brand-kits');

          if (response['success'] == true) {
            final List<dynamic> data = response['data'] ?? [];
            brandKits.value = data.map((json) => BrandKit.fromJson(json)).toList();

            // حفظ في Hive
            if (_brandBox != null) {
              for (var brand in brandKits) {
                await _brandBox!.put(brand.id, brand);
              }
            }

            // تحديد البراند النشط
            activeBrandKit.value = brandKits.firstWhereOrNull((b) => b.isActive);
            print('📦 Loaded ${brandKits.length} brand kits from server');
            return;
          }
        } catch (e) {
          print('⚠️ Failed to load from server: $e');
        }
      }

      // التحميل من Hive إذا فشل Backend أو غير متاح
      if (_brandBox != null) {
        brandKits.value = _brandBox!.values.toList();
        activeBrandKit.value = brandKits.firstWhereOrNull((b) => b.isActive);
        print('📦 Loaded ${brandKits.length} brand kits from local storage');
      }
    } catch (e) {
      print('❌ Error loading brand kits: $e');

      // Fallback to Hive
      if (_brandBox != null) {
        brandKits.value = _brandBox!.values.toList();
        activeBrandKit.value = brandKits.firstWhereOrNull((b) => b.isActive);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// حذف Brand Kit
  Future<bool> deleteBrandKit(String id) async {
    try {
      // حذف محلياً أولاً
      if (_brandBox != null) {
        await _brandBox!.delete(id);
      }
      brandKits.removeWhere((b) => b.id == id);

      if (activeBrandKit.value?.id == id) {
        activeBrandKit.value = brandKits.firstOrNull;
      }

      // محاولة الحذف من السيرفر
      if (_httpService != null) {
        try {
          await _httpService!.delete('/brand-kits/$id');
          print('✅ Brand Kit deleted from server');
        } catch (e) {
          print('⚠️ Failed to delete from server: $e');
        }
      }

      print('✅ Brand Kit deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting brand kit: $e');
      return false;
    }
  }

  /// تفعيل Brand Kit
  Future<void> setActiveBrandKit(BrandKit brandKit) async {
    // إلغاء تفعيل الكل
    for (var brand in brandKits) {
      brand.isActive = false;
      await updateBrandKit(brand);
    }

    // تفعيل البراند المحدد
    brandKit.isActive = true;
    await updateBrandKit(brandKit);
    activeBrandKit.value = brandKit;
  }

  // ==================== TRENDING ANALYSIS ====================

  /// تحليل الترندات في مجال البراند
  Future<void> analyzeTrends(BrandKit brandKit) async {
    try {
      isAnalyzing.value = true;
      print('🔍 Analyzing trends for ${brandKit.industry}...');

      if (_httpService != null) {
        try {
          final response = await _httpService!.post(
            '/brand-kits/${brandKit.id}/analyze-trends',
            body: {
              'industry': brandKit.industry,
              'keywords': brandKit.keywords,
              'target_audience': brandKit.targetAudience,
            },
          );

          if (response['success'] == true) {
            final List<dynamic> trendsData = response['data']['trends'] ?? [];
            trendingIdeas.value = trendsData
                .map((json) => TrendingIdea.fromJson(json))
                .toList();

            // حفظ في البراند
            brandKit.trendingData = {
              'trends': trendsData,
              'analyzed_at': DateTime.now().toIso8601String(),
            };
            await updateBrandKit(brandKit);

            print('✅ Found ${trendingIdeas.length} trending ideas');
            return;
          }
        } catch (e) {
          print('⚠️ Failed to analyze trends from server: $e');
        }
      }

      // Generate mock trends if API not available
      trendingIdeas.value = _generateMockTrends(brandKit);
      print('✅ Generated ${trendingIdeas.length} mock trending ideas');
    } catch (e) {
      print('❌ Error analyzing trends: $e');
    } finally {
      isAnalyzing.value = false;
    }
  }

  List<TrendingIdea> _generateMockTrends(BrandKit brandKit) {
    return [
      TrendingIdea(
        id: 'trend_1',
        title: 'محتوى تعليمي قصير',
        description: 'الفيديوهات القصيرة التعليمية تحقق أعلى معدلات المشاركة في مجال ${brandKit.industry}',
        category: brandKit.industry,
        source: 'تحليل السوق',
        popularity: 85,
        hashtags: ['تعليم', 'نصائح', brandKit.industry.toLowerCase()],
        discoveredAt: DateTime.now(),
      ),
      TrendingIdea(
        id: 'trend_2',
        title: 'قصص النجاح',
        description: 'مشاركة قصص النجاح والتجارب الحقيقية تزيد من التفاعل بنسبة 60%',
        category: 'محتوى',
        source: 'تحليل المحتوى',
        popularity: 78,
        hashtags: ['نجاح', 'تجربة', 'إلهام'],
        discoveredAt: DateTime.now(),
      ),
      TrendingIdea(
        id: 'trend_3',
        title: 'محتوى تفاعلي',
        description: 'استطلاعات الرأي والأسئلة تشجع المتابعين على المشاركة',
        category: 'تفاعل',
        source: 'ترندات السوشال ميديا',
        popularity: 72,
        hashtags: ['تفاعل', 'رأيك', 'شاركنا'],
        discoveredAt: DateTime.now(),
      ),
    ];
  }

  // ==================== BRAND OPTIMIZATION ====================

  /// توليد اقتراحات لتحسين البراند بناءً على الترندات
  Future<void> generateBrandSuggestions(BrandKit brandKit) async {
    try {
      isAnalyzing.value = true;
      print('💡 Generating brand optimization suggestions...');

      if (_httpService != null) {
        try {
          final response = await _httpService!.post(
            '/brand-kits/${brandKit.id}/suggestions',
            body: {
              'trends': trendingIdeas.map((t) => t.toJson()).toList(),
              'current_brand': brandKit.toJson(),
            },
          );

          if (response['success'] == true) {
            final List<dynamic> suggestionsData = response['data']['suggestions'] ?? [];
            suggestions.value = suggestionsData
                .map((json) => BrandSuggestion.fromJson(json))
                .toList();

            // حفظ في البراند
            brandKit.aiSuggestions = {
              'suggestions': suggestionsData,
              'generated_at': DateTime.now().toIso8601String(),
            };
            await updateBrandKit(brandKit);

            print('✅ Generated ${suggestions.length} suggestions');
            return;
          }
        } catch (e) {
          print('⚠️ Failed to generate suggestions from server: $e');
        }
      }

      // Generate mock suggestions if API not available
      suggestions.value = _generateMockSuggestions(brandKit);
      print('✅ Generated ${suggestions.length} mock suggestions');
    } catch (e) {
      print('❌ Error generating suggestions: $e');
    } finally {
      isAnalyzing.value = false;
    }
  }

  List<BrandSuggestion> _generateMockSuggestions(BrandKit brandKit) {
    return [
      BrandSuggestion(
        type: 'keyword',
        title: 'إضافة كلمات مفتاحية جديدة',
        description: 'أضف كلمات مفتاحية متعلقة بالترندات الحالية لزيادة الوصول',
        value: ['محتوى', 'تفاعلي', 'قصص'],
        reason: 'هذه الكلمات تحقق معدلات بحث عالية في مجالك',
        confidence: 85,
        applied: false,
      ),
      BrandSuggestion(
        type: 'tone',
        title: 'تعديل نبرة المحتوى',
        description: 'استخدم نبرة أكثر تفاعلية وقربًا من الجمهور',
        value: 'friendly',
        reason: 'النبرة الودية تزيد من التفاعل بنسبة 40%',
        confidence: 78,
        applied: false,
      ),
      BrandSuggestion(
        type: 'color',
        title: 'إضافة لون جديد',
        description: 'أضف اللون الأخضر لإبراز الثقة والنمو',
        value: '#4CAF50',
        reason: 'اللون الأخضر يعكس الإيجابية ويجذب الانتباه',
        confidence: 72,
        applied: false,
      ),
    ];
  }

  /// تطبيق اقتراح على البراند
  Future<bool> applySuggestion(BrandKit brandKit, BrandSuggestion suggestion) async {
    try {
      switch (suggestion.type) {
        case 'keyword':
          if (suggestion.value is String) {
            if (!brandKit.keywords.contains(suggestion.value)) {
              brandKit.keywords.add(suggestion.value as String);
            }
          } else if (suggestion.value is List) {
            for (var keyword in suggestion.value) {
              if (!brandKit.keywords.contains(keyword.toString())) {
                brandKit.keywords.add(keyword.toString());
              }
            }
          }
          break;

        case 'color':
          if (suggestion.value is String) {
            if (!brandKit.primaryColors.contains(suggestion.value)) {
              brandKit.primaryColors.add(suggestion.value as String);
            }
          }
          break;

        case 'tone':
          if (suggestion.value is String) {
            brandKit.tone = suggestion.value as String;
          }
          break;

        case 'slogan':
          if (suggestion.value is String) {
            brandKit.slogan = suggestion.value as String;
          }
          break;
      }

      // تحديث البراند
      final success = await updateBrandKit(brandKit);

      if (success) {
        // تحديث حالة الاقتراح بإنشاء كائن جديد
        final index = suggestions.indexWhere((s) => s.title == suggestion.title);
        if (index != -1) {
          suggestions[index] = BrandSuggestion(
            type: suggestion.type,
            title: suggestion.title,
            description: suggestion.description,
            value: suggestion.value,
            reason: suggestion.reason,
            confidence: suggestion.confidence,
            applied: true,
          );
        }

        print('✅ Applied suggestion: ${suggestion.title}');
      }

      return success;
    } catch (e) {
      print('❌ Error applying suggestion: $e');
      return false;
    }
  }

  // ==================== HELPERS ====================

  /// الحصول على Brand Kit النشط
  BrandKit? get activeBrand => activeBrandKit.value;

  /// الحصول على ألوان البراند النشط
  List<String> get brandColors {
    if (activeBrand == null) return [];
    return [...activeBrand!.primaryColors, ...activeBrand!.secondaryColors];
  }

  /// الحصول على كلمات مفتاحية للبراند النشط
  List<String> get brandKeywords {
    if (activeBrand == null) return [];
    return activeBrand!.keywords;
  }

  /// الحصول على نبرة البراند
  String get brandTone {
    if (activeBrand == null) return 'professional';
    return activeBrand!.tone;
  }

  /// إحصائيات
  int get totalBrands => brandKits.length;
  int get totalTrends => trendingIdeas.length;
  int get totalSuggestions => suggestions.length;
  int get appliedSuggestions => suggestions.where((s) => s.applied).length;
}
