# Integrating In-App Purchases in React Native: Step 3

[← Previous: Step 2 - Installing Iaptic](tutorial-step2.html) | [Next: Step 4 - Service Layer →](tutorial-step4.html)

## Step 3: Creating the Configuration File

With react-native-iaptic installed, we now need to create a configuration file. This file will define your IAP products, entitlements, and connection settings. The configuration file is central to the Iaptic integration - it serves as a single source of truth for all IAP-related settings.

### 1. Create the src Directory

First, let's create a directory to organize our source code:

```bash
mkdir -p src
```

### 2. Create the Config.ts File

Now, create a file named `Config.ts` in the src directory. This file will store all your Iaptic settings and your products settings.

Let's start by creating the `src/Config.ts` file:

```typescript
import { IapticConfig, IapticVerbosity } from "react-native-iaptic";

/**
 * Configuration class for the app
 * 
 * This class contains all the configuration settings for the app,
 * including the Iaptic configuration for in-app purchases.
 */
export class Config {
    
  // TODO: Add your configuration here
  
}
```

### 3. App Credentials and Identifiers

Let's start by adding the following:

```typescript
    /**
    * Iaptic configuration
    * 
    * This configuration is used by the react-native-iaptic library
    * to set up in-app purchases and subscriptions.
    */
   static iaptic: IapticConfig = {
     
     // Your app name in the Iaptic dashboard
     appName: 'your.app.name',
     
     // Your public API key from the Iaptic dashboard
     publicKey: 'your-public-key',
     
     // Your iOS bundle identifier
     iosBundleId: 'com.yourcompany.yourapp',
     
     // Set verbosity level for debugging
     verbosity: IapticVerbosity.DEBUG,
     
     // Define your products and their associated entitlements
     products: [
       { id: 'subscription1', type: 'paid subscription', entitlements: ['basic'] },
       { id: 'subscription2', type: 'paid subscription', entitlements: ['basic', 'premium'] },
       { id: 'monthly_with_intro', type: 'paid subscription', entitlements: ['basic', 'premium', 'pro'] }
     ]
   };
```

- **appName**: The unique identifier for your app in the Iaptic dashboard
- **publicKey**: Your Iaptic public API key that authenticates your app with the Iaptic service (generated in the Iaptic dashboard)
- **iosBundleId**: The iOS bundle identifier from your App Store Connect account (used for iOS receipt validation)
- **verbosity**: Controls the level of logging from the Iaptic library
  - Options: `NONE`, `ERROR`, `WARNING`, `INFO`, `DEBUG`
  - Use `DEBUG` during development for detailed logs
  - Switch to `NONE` or `ERROR` for production builds
- **products**: Array of product definitions, where each product has:
  - **id**: The product identifier that matches your App Store/Play Store product ID
  - **type**: The type of product ('paid subscription')
  - **entitlements**: The list of entitlements associated with the product. More details will follow in the next section.

### 4. Entitlements

In Iaptic, entitlements ("basic", "premium"...) are specific access rights or features that you associate with each subscription product. Instead of checking which product a user bought, your app simply checks if they have a specific entitlement. This makes your code cleaner and easier to maintain.

For example, with the products defined in the code, you can simply check `IapticRN.checkEntitlement('premium')` to enable premium features, without needing to know whether the user purchased `subscription2` or `monthly_with_intro`.

This approach decouples your feature access logic from the specific products, making it easier to manage and update your subscription offerings without changing code throughout your app.

Let's also add the entitlements to the `Config.ts` file. The information in the object entitlements will be diplayed in the subscription management screen.

```typescript
/**
 * Entitlement labels for UI display
 * 
 * These labels and descriptions will be shown in your subscription management screen
 */
static entitlements = {
  basic: {
    label: "Basic Access",
    detail: "Access to Basic Features"
  },
  premium: {
    label: "Premium Access",
    detail: "Access to Premium Features"
  },
  pro: {
    label: "Pro Access",
    detail: "Access to All Pro Features"
  }
};
```

- **entitlements**: Object mapping entitlement IDs to their display labels and descriptions
- Each entitlement has:
  - **label**: Short name displayed in the subscription UI
  - **detail**: Longer description explaining what the entitlement provides

This allows the following display in the subscription management screen.

<img src="img/iapui2.png" alt="Subscription view" style="max-width: 300px; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">

### 5. Terms and Conditions URL

Last but not least, let's add the terms and conditions URL to the `Config.ts` file:

```typescript
/**
 * URL for terms and conditions
 * 
 * This URL will be displayed in the subscription UI
 */
static termsUrl = 'https://www.example.com/terms';
```

- **termsUrl**: URL to your terms and conditions (displayed in the subscription UI)
- This link will be shown to users in the subscription management screen, allowing them to review your terms before purchase

### 6. Final Config.ts Implementation

After adding all the components we've discussed, your complete `Config.ts` file should look like this:

```typescript
import { IapticConfig, IapticVerbosity } from "react-native-iaptic";

/**
 * Configuration class for the app
 * 
 * This class contains all the configuration settings for the app,
 * including the Iaptic configuration for in-app purchases.
 */
export class Config {
  /**
   * Iaptic configuration
   * 
   * This configuration is used by the react-native-iaptic library
   * to set up in-app purchases and subscriptions.
   */
  static iaptic: IapticConfig = {
    
    // Your app name in the Iaptic dashboard
    appName: 'your.app.name',
    
    // Your public API key from the Iaptic dashboard
    publicKey: 'your-public-key',
    
    // Your iOS bundle identifier
    iosBundleId: 'com.yourcompany.yourapp',
    
    // Set verbosity level for debugging
    verbosity: IapticVerbosity.DEBUG,
    
    // Define your products and their associated entitlements
    products: [
      { id: 'subscription1', type: 'paid subscription', entitlements: ['basic'] },
      { id: 'subscription2', type: 'paid subscription', entitlements: ['basic', 'premium'] },
      { id: 'monthly_with_intro', type: 'paid subscription', entitlements: ['basic', 'premium', 'pro'] }
    ]
  };
  
  /**
   * Entitlement labels for UI display
   * 
   * These labels and descriptions will be shown in your subscription UI
   */
  static entitlements = {
    basic: {
      label: "Basic Access",
      detail: "Access to Basic Features"
    },
    premium: {
      label: "Premium Access",
      detail: "Access to Premium Features"
    },
    pro: {
      label: "Pro Access",
      detail: "Access to All Pro Features"
    }
  };
  
  /**
   * URL for terms and conditions
   * 
   * This URL will be displayed in the subscription UI
   */
  static termsUrl = 'https://www.example.com/terms';
}
```

### 7. What's Next?

Now that we have set up the configuration file, in the next step we'll create the AppService class that will handle the initialization of Iaptic, track subscription changes, and provide methods to check entitlements.

[← Previous: Step 2 - Installing Iaptic](tutorial-step2.html) | [Next: Step 4 - Service Layer →](tutorial-step4.html) 