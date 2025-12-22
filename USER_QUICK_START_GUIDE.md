# 📱 Social Media Manager - Quick User Guide

## 🎯 Core User Flows

### Flow 1️⃣: Connect Social Media Accounts
```
Home Dashboard
    ↓
Tap "Social Accounts" or "Connect Accounts"
    ↓
See Available Platforms:
📘 Facebook  •  📷 Instagram  •  𝕏 Twitter
💼 LinkedIn  •  🎵 TikTok   •  📌 Pinterest
🔵 Bluesky   •  ▶️ YouTube
    ↓
Tap Platform (e.g., Instagram)
    ↓
OAuth Browser Opens
    ↓
Grant Permission & Authenticate
    ↓
Return to App → Account Connected ✅
    ↓
Repeat for Other Platforms (supports multiple per platform)
```

**Status**: ✅ FULLY WORKING
- Multiple accounts per platform supported
- Disconnect with confirmation
- Real-time sync with backend

---

### Flow 2️⃣: Generate Content with AI
```
Dashboard / Content Tab
    ↓
Tap "Create Content" or "Generate Post"
    ↓
Choose Content Type:
📝 Text Post  •  🖼️ Image  •  📹 Video  •  🎠 Carousel
    ↓
Option A: USE AI (Recommended for quick content)
    ├─ Tap "Generate with AI"
    ├─ Enter Topic/Idea
    ├─ Choose AI Model: ChatGPT or Google Gemini
    ├─ Select Tone: Professional / Casual / Funny / Inspirational
    ├─ Select Language: Arabic / English
    ├─ Tap "Generate"
    └─ AI writes professional content in seconds ⚡
    
Option B: MANUAL WRITE
    ├─ Tap "Write Manually"
    ├─ Enter Title & Content
    ├─ Add Hashtags (auto-suggested)
    └─ Upload Images from Gallery
    ↓
Preview Content
    ↓
Select Target Platforms:
☑️ Facebook  ☑️ Instagram  ☑️ Twitter  ☑️ LinkedIn
    ↓
Choose Action:
🚀 Publish Now
   ↓ (Immediately to all selected platforms)
   
📅 Schedule Later
   ├─ Pick Date from Calendar
   ├─ Select Time (AI recommends best time)
   └─ Confirm
    ↓
Done! ✅ Content Posted/Scheduled
```

**Status**: ✅ FULLY WORKING
- ChatGPT & Gemini integration active
- Multi-language support
- Instant distribution to 8 platforms
- Flexible scheduling

---

### Flow 3️⃣: Manage Scheduled Posts
```
Content Screen → "Scheduled" Tab
    ↓
View All Scheduled Posts with:
📅 Date & Time
📱 Platforms
✏️ Content Preview
    ↓
Actions per Post:
• Edit content
• Change schedule time
• Delete/Cancel
• Preview before publishing
    ↓
At Scheduled Time:
✅ Post Auto-Publishes to All Platforms
```

**Status**: ✅ FULLY WORKING
- Calendar-based scheduling
- Edit scheduled posts
- AI-recommended posting times
- Bulk scheduling support

---

### Flow 4️⃣: Create Community Post (NEW!)
```
Home Dashboard
    ↓
Tap "Community" Tab
    ↓
Tap "Create Post" Button
    ↓
SUBSCRIPTION CHECK:
If Free Tier User → 🔒 LOCKED
    ├─ Message: "Only subscribers can post"
    ├─ Button: "Upgrade to Pro"
    └─ Feature blocked
    
If Paid Subscriber → ✅ UNLOCKED
    ├─ See Full Post Creation Form
    ├─ Enter Title (optional)
    ├─ Write Content (required)
    ├─ Tap "📸 Add Photos" Button
    │   ├─ Multi-image gallery opens
    │   ├─ Select 1-10 images
    │   └─ Preview in gallery
    ├─ Add Tags (comma-separated)
    ├─ Toggle Options:
    │   ├─ Allow Comments: Yes/No
    │   └─ Visibility: Public / Private
    └─ Tap "🚀 Publish"
    ↓
Post Appears in Community Feed
    ├─ User avatar & name shown
    ├─ Subscription tier badge
    ├─ Images in gallery
    ├─ Like/Comment buttons
    └─ Share button
    ↓
Group Stats Auto-Update:
    ├─ Post count incremented
    ├─ Group engagement tracked
    └─ Revenue attributed
```

**Status**: ✅ FULLY WORKING
- Subscription access control working
- Image gallery with multi-select
- Firestore integration
- Group stats auto-update

---

### Flow 5️⃣: View Analytics
```
Dashboard / Analytics Tab
    ↓
See Performance Metrics:
📊 Impressions (total views)
❤️ Likes & Engagement Rate
💬 Comments & Shares
👥 Reach (unique users)
📈 Growth Trend
    ↓
Filter by:
• Time Period (Last 7 days, Month, Year)
• Platform (Facebook, Instagram, etc.)
• Content Type (Posts, Videos, etc.)
    ↓
Tap Post to See Details:
✅ Platform-specific metrics
✅ Audience demographics
✅ Best performing times
✅ Content recommendations
```

**Status**: ✅ FULLY WORKING
- Real-time metrics
- Multi-platform aggregation
- Historical trend analysis
- AI-powered insights

---

### Flow 6️⃣: Upgrade to Premium
```
Any Screen
    ↓
Tap "Upgrade" or "View Plans"
    ↓
See Subscription Plans:

INDIVIDUAL PLANS:
┌─────────────────────┐
│ 99 AED Economy      │ ← NEW!
│ ✓ 2 accounts        │
│ ✓ 20 posts/month    │
│ ✓ Basic analytics   │
│ [Subscribe] Button  │
└─────────────────────┘

┌─────────────────────┐
│ 59 AED Pro (Popular)│
│ ✓ 5 accounts        │
│ ✓ 100 posts/month   │
│ ✓ AI features       │
│ ✓ Advanced analytics│
│ [Subscribe] Button  │
└─────────────────────┘

BUSINESS PLANS:
┌─────────────────────┐
│ 159 AED Economy     │ ← NEW!
│ ✓ 5 accounts        │
│ ✓ 100 posts/month   │
│ ✓ AI + Team (2)     │
│ ✓ Professional      │
│ [Subscribe] Button  │
└─────────────────────┘

┌─────────────────────┐
│ 199 AED Growth      │
│ ✓ 25 accounts       │
│ ✓ 500 posts/month   │
│ ✓ API access        │
│ ✓ 10 team members   │
│ [Subscribe] Button  │
└─────────────────────┘

(More plans available...)
    ↓
Tap Plan to Subscribe
    ↓
Payment Screen:
├─ Plan details shown
├─ Enter Name
├─ Enter Email
├─ Enter Phone
├─ Tap "Secure Payment"
    ↓
Paymob Payment Gateway Opens
    ├─ Credit/Debit Card
    ├─ Mobile Wallet
    └─ Bank Transfer (pending)
    ↓
Payment Processed
    ↓
Subscription Activated ✅
    ├─ Features unlocked
    ├─ Account updated
    └─ Email confirmation sent
```

**Status**: ✅ FULLY WORKING
- 8 subscription plans available
- New 99 AED & 159 AED plans
- Paymob payment integration
- Instant activation

---

## 🎯 What Users Can Do RIGHT NOW

✅ **Connect Accounts**
- Instagram (personal & business)
- Facebook (page & profile)
- Twitter/X
- LinkedIn (profile & page)
- TikTok
- Pinterest
- Bluesky
- YouTube

✅ **Generate Content**
- AI-written posts (ChatGPT)
- Alternative AI (Google Gemini)
- Manual composition
- Image uploads
- Video uploads
- Carousel posts
- Stories/Reels

✅ **Publish Content**
- Instant to 8 platforms
- Scheduled for later
- Bulk scheduling
- Auto-optimal times
- Platform-specific optimization

✅ **Community Features**
- Create community groups
- Post in communities (subscribers only)
- Organize events
- RSVP to events
- Community revenue tracking

✅ **Manage Subscriptions**
- View 8 pricing plans
- Upgrade instantly
- Pay via Paymob
- Access premium features
- Track billing

✅ **Track Analytics**
- Real-time metrics
- Platform-by-platform breakdown
- Audience insights
- Content performance
- Growth recommendations

---

## 🚨 Important Notes for Users

### 📌 Community Posts
- **Only paid subscribers can post** (free tier blocked)
- Free users see "Upgrade" button with CTA
- Paid subscribers get:
  - Rich text editor
  - Multi-image gallery
  - Tag system
  - Comment controls
  - Visibility options

### 💳 Payment Info
- **New 99 AED plan** for individuals (2 accounts, 20 posts/month)
- **New 159 AED plan** for businesses (5 accounts, 100 posts/month)
- All payments via secure Paymob gateway
- Instant activation after payment
- Can upgrade/downgrade anytime

### ⏰ Scheduling Tips
- App shows **AI-recommended posting times** based on audience
- Peak engagement times highlighted
- Schedule up to 365 days in advance
- Timezone automatically detected

### 🤖 AI Content Generation
- **Free tier limited**: 5 AI generations/month
- **Pro tier unlimited**: Unlimited AI generations
- Supports Arabic & English
- Tone customization available
- Hashtag auto-suggestion

---

## 📞 Support & Help

**In-App Support:**
- Tap Help icon in Settings
- Create support ticket
- Chat with support team
- View knowledge base

**Common Issues & Solutions:**
1. Account not connecting?
   - Check internet connection
   - Verify OAuth permissions
   - Try reconnecting

2. Content not publishing?
   - Verify account still connected
   - Check content length
   - Try republishing

3. Analytics not updating?
   - Pull to refresh
   - Check platform connections
   - Wait 15 minutes for sync

4. Payment failed?
   - Check card details
   - Verify funds available
   - Try alternative payment method
   - Contact support

---

## 🎓 Getting Started Checklist

- [ ] Download app
- [ ] Create account
- [ ] Connect first social media account
- [ ] Generate test post with AI
- [ ] Publish to 1 platform
- [ ] View analytics
- [ ] Join community
- [ ] Create community post (if subscribed)
- [ ] View pricing plans
- [ ] Upgrade to Pro (optional)
- [ ] Schedule a post
- [ ] Enjoy! 🎉

---

**Version**: 1.0  
**Last Updated**: November 18, 2025  
**Status**: ✅ All Features Working

