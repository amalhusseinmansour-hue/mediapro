import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TmpFME1qTXNJbTVoYldVaU9pSXhOelkwTkRReU5UY3dMakl4TXpnNEluMC5iR2g0ZTVHSGY2YjhpNzc4Yjl0YVVwLWZYUThrN0xzUE5GT2dtUmRxS1I1UnZhc1YtMW51TEVVbFJUYlN4TTVzZVRIRlltdFdvUTV6R0sxbDM1TjJpZw==';
  
  print('Testing Paymob API Key...');
  
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('https://uae.paymob.com/api/auth/tokens'));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'api_key': apiKey}));
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('Status Code: ${response.statusCode}');
    print('Response: $responseBody');
    
    if (response.statusCode == 201) {
      print('✅ API Key is VALID!');
    } else {
      print('❌ API Key is INVALID or Expired.');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
