# Environment Configuration Template

Copy the content below to create a `.env` file in your project root:

```env
# ================================================
# MA'A YEGUE - Environment Configuration Template
# ================================================
# Copy this content to .env file and fill in your actual credentials
# NEVER commit the .env file with real credentials to git!

# ================================================
# FIREBASE CONFIGURATION
# ================================================
# Note: Firebase credentials are already in firebase_options.dart
# These are only needed if you want to override them
FIREBASE_API_KEY=
FIREBASE_AUTH_DOMAIN=
FIREBASE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_APP_ID=

# ================================================
# GOOGLE GEMINI AI CONFIGURATION
# ================================================
# Get your API key from: https://makersuite.google.com/app/apikey
GEMINI_API_KEY=your_gemini_api_key_here

# ================================================
# CAMPAY PAYMENT GATEWAY (Primary - Mobile Money Cameroon)
# ================================================
# Sign up at: https://www.campay.net
CAMPAY_BASE_URL=https://api.campay.net
CAMPAY_API_KEY=your_campay_api_key_here
CAMPAY_SECRET=your_campay_secret_here
CAMPAY_WEBHOOK_SECRET=your_campay_webhook_secret_here

# ================================================
# NOUPIA PAYMENT GATEWAY (Fallback - Mobile Money)
# ================================================
# Sign up at: https://www.noupia.com  
NOUPAI_BASE_URL=https://api.noupai.com
NOUPAI_API_KEY=your_noupai_api_key_here
NOUPAI_WEBHOOK_SECRET=your_noupai_webhook_secret_here

# ================================================
# STRIPE PAYMENT (International Credit Cards)
# ================================================
# Get keys from: https://dashboard.stripe.com/apikeys
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_stripe_webhook_secret_here

# ================================================
# APPLICATION CONFIGURATION
# ================================================
APP_ENV=development  # Options: development, staging, production
APP_NAME=Ma'a yegue
APP_VERSION=1.0.0
BASE_URL=https://mayegue.app

# ================================================
# DEFAULT ADMIN CONFIGURATION
# ================================================
# Default admin user for initial setup
DEFAULT_ADMIN_EMAIL=admin@mayegue.app
DEFAULT_ADMIN_PASSWORD=Change_This_Secure_Password_123!
DEFAULT_ADMIN_NAME=Administrateur Mayegue

# ================================================
# SECURITY
# ================================================
# Generate a random string for JWT secret (if needed)
JWT_SECRET=your_random_jwt_secret_key_here
ENCRYPTION_KEY=your_32_character_encryption_key

# ================================================
# FEATURE FLAGS
# ================================================
ENABLE_2FA=true
ENABLE_GOOGLE_AUTH=true
ENABLE_FACEBOOK_AUTH=true
ENABLE_PHONE_AUTH=true
ENABLE_AI_ASSISTANT=true
ENABLE_OFFLINE_MODE=true

# ================================================
# NEWSLETTER & MARKETING
# ================================================
# Mailchimp, SendGrid, or other email service
EMAIL_SERVICE_API_KEY=your_email_service_api_key_here
NEWSLETTER_LIST_ID=your_newsletter_list_id_here

# ================================================
# ANALYTICS (Optional)
# ================================================
GOOGLE_ANALYTICS_ID=
MIXPANEL_TOKEN=

# ================================================
# MONITORING & LOGGING (Optional)
# ================================================
SENTRY_DSN=
LOGGLY_TOKEN=

# ================================================
# NOTES
# ================================================
# 1. For development: Use test/sandbox API keys
# 2. For production: Use live API keys and set APP_ENV=production
# 3. Keep this file secure and never share it publicly
# 4. Restart your app after changing these values
```

## How to Create the .env File

1. Create a new file named `.env` in the root of your project
2. Copy the content above (without the markdown code blocks)
3. Fill in your actual API keys and credentials
4. Save the file
5. Make sure `.env` is in your `.gitignore` file (it should already be there)

## Where to Get API Keys

- **Gemini AI**: https://makersuite.google.com/app/apikey
- **CamPay**: https://www.campay.net
- **Noupia**: Contact their support or visit their website
- **Stripe**: https://dashboard.stripe.com/apikeys

