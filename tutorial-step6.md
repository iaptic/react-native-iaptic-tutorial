# Integrating In-App Purchases in React Native: Step 6

[← Previous: Step 5 - Managing Entitlements](tutorial-step5.html) 

## Step 6: Making Purchases

### 1. Update Subscription Button

<img src="img/buttons.png" alt="App with subscription buttons" style="max-width: 300px; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">

Now, let's activate our subscription button by linking it to the `IapticRN.presentSubscriptionView()` method. Let's go back to our App.tsx Class and update our subscriptionButton:

```typescript
/* App.tsx file */

<TouchableOpacity
    style={[
    styles.button,
    styles.subscriptionButton,
    ]}
    onPress={() => {
    IapticRN.presentSubscriptionView();
    }}
>
    <Text style={styles.buttonText}>{!entitlements.includes('basic') ? 'Subscribe To Unlock' : 'Manage Subscription'}</Text>
</TouchableOpacity>
```
#### What is presentSubscriptionView()?

`IapticRN.presentSubscriptionView()` is a direct method provided by the Iaptic SDK that:

1. Programmatically displays the subscription view that is provided by iaptic. No need to develop your own subscription view.
2. Shows all available subscription options configured in your `Config.ts` file
3. Handles the entire purchase flow automatically
4. Closes the view once a purchase is completed or canceled

#### What does the following mean?
```typescript
/* App.tsx file */

    <Text style={styles.buttonText}>{!entitlements.includes('basic') ? 'Subscribe To Unlock' : 'Manage Subscription'}</Text>
```
This line uses a ternary operator to dynamically change the button text based on the user's subscription status:

1. When the user is not subscribed: If the user doesn't have the 'basic' entitlement (meaning they don't have any subscription), the button displays "Subscribe To Unlock". This encourages non-subscribers to take action.
2. When the user is already subscribed: If the user has at least the 'basic' entitlement (meaning they have an active subscription), the button changes to "Manage Subscription". This allows existing subscribers to modify their subscription or see what they currently have.

### 2. Integrating the Subscription View
Instead of having to develop a subscription view yourself, Iaptic offers you the possibility of integrating the IapticSubscriptionView component. When we click on the subscription button, this component will open and allow the user to make his/her iap purchase. The information in this view will be filled thanks to the Config file.

<img src="img/iapui.png" alt="Subscription view" style="max-width: 300px; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">

Let's add the following to the App.tsx file:

```typescript
/* App.tsx file */

...
// Add these two lines to the imports
import { IapticRN, IapticSubscriptionView } from 'react-native-iaptic';
import { Config } from './src/Config';

...

// Add the following after the scroll View
//   </ScrollView>

      {/* This is the IapticSubscriptionView component, which displays the subscription options */}
      <IapticSubscriptionView
        entitlementLabels={Config.entitlements}
        onPurchaseComplete={() => {
          iapService.handlePurchaseComplete();
        }}
        termsUrl={Config.termsUrl}
        theme={{
          primaryColor: '#FF7A00',
          secondaryColor: '#FF0000',
        }}
      />
```

The component that will be displayed takes several key props:

1. entitlementLabels: Connects to your Config.entitlements definitions, displaying user-friendly names and descriptions for each subscription tier.
2. onPurchaseComplete: A callback function that executes when a user successfully completes a purchase. We will add the function handlePurchaseComplete to AppService that will play this role.
3. termsUrl: Provides a link to your terms and conditions, it will be displayed in the component.
4. theme: An object that allows you to customize the visual appearance of the subscription view to match your app's branding. Here, we're setting custom primary and secondary colors.

This component creates a complete subscription experience that handles all the complexities of displaying products, processing payments, and managing purchase flows while remaining visually integrated with your application.

### 3. Adding function handlePurchaseComplete to AppService

Let's update our `AppService.ts` file to include the `handlePurchaseComplete` function. We have decided to make an alert ad some logs in this function.

```typescript
/* AppService.ts file */

...

  /**
   * Called after a successful purchase
   * Shows confirmation to user and logs purchase details
   */
  handlePurchaseComplete() {
    Alert.alert('Thank you for your purchase');
    console.log(IapticRN.listEntitlements());
    console.log(IapticRN.getActiveSubscription());
  }

```

### 4. Complete code

Good news: we have completed our work!

Here's the complete AppService class:

```typescript
/* AppService.ts file */

import { Platform, Alert, ToastAndroid } from 'react-native';
import { IapticError, IapticSeverity, IapticOffer, IapticRN } from 'react-native-iaptic';
import { Config } from './Config';

/**
 * AppService - Core service for managing in-app purchases
 * 
 * This class handles the initialization of the IAP system,
 * tracks subscription states, and provides methods for
 * checking user entitlements and handling purchases.
 */
export class AppService {

  DEBUG = true;

  showAlert(title: string, message: string, debug: string = '') {
    if (this.DEBUG) {
      Alert.alert(title, message + '\n\n' + debug);
    }
    else {
      Alert.alert(title, message);
    }
  }

  log(message: string, severity: IapticSeverity = IapticSeverity.INFO) {
    const SYMBOLS = ['💡', '🔔', '❌'];
    console.log(`${new Date().toISOString()} ${SYMBOLS[severity]} ${message}`);
  }

  /**
   * Creates a new AppService instance
   * @param setEntitlements - Callback function to update UI with current entitlements
   *                          This function is called whenever entitlements change
   */
  constructor(private setEntitlements: (entitlements: string[]) => void) {
  }

  /**
   * Called when the app starts up.
   * Initializes the IAP system and sets up event listeners
   * 
   * @returns a destructor function that should be called when the app is closed
   *          to properly clean up IAP resources
   */
  onAppStartup() {
    this.log('onAppStartup');
    this.initializeIaptic();
    // Return cleanup function that React will call when component unmounts
    return () => {
      IapticRN.destroy();
    }
  }

  async initializeIaptic() {
    try {
      // Set up listener for subscription changes (renewals, cancellations, etc.)
      IapticRN.addEventListener('subscription.updated', (reason, purchase) => {
        this.log('🔄 Subscription updated: ' + reason + ' for ' + JSON.stringify(purchase));
        // Update UI with new entitlements after subscription change
        this.setEntitlements(IapticRN.listEntitlements());
      });

      // Initialize IAP system with app-specific configuration
      await IapticRN.initialize(Config.iaptic);
      // Set a username to associate purchases with this user
      // This helps with purchase restoration and user identification
      IapticRN.setApplicationUsername('iaptic-rn-demo-user');

      // Update UI with initial entitlements (if any existing purchases)
      this.setEntitlements(IapticRN.listEntitlements());
    }
    catch (err: any) {
      this.log('Error initializing iaptic: ' + err.message);
      if (err instanceof IapticError) {
        this.showAlert('Error', err.localizedMessage, err.debugMessage);
      }
      else {
        this.showAlert('Error', err.message);
      }
    }
  }

  /**
   * Check if a feature is unlocked based on user's entitlements
   * Used to gate premium features in the app
   * 
   * @param featureId - The feature ID to check (e.g., "premium", "pro", "basic")
   */
    public checkFeatureAccess(featureId: string) {
      // Check if user has the required entitlement
      if (IapticRN.checkEntitlement(featureId)) {
        Alert.alert(`"${featureId}" feature is unlocked.`);
      }
      else {
        Alert.alert(`Please subscribe to the app to unlock feature "${featureId}".`);
      }
    }

  /**
   * Called after a successful purchase
   * Shows confirmation to user and logs purchase details
   */
  handlePurchaseComplete() {
    Alert.alert('Thank you for your purchase');
    console.log(IapticRN.listEntitlements());
    console.log(IapticRN.getActiveSubscription());
  }

}  

```

Here's the complete App.tsx class:

```typescript
/* App.tsx file */

/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, { useEffect, useState, useRef } from 'react';
import { StyleSheet, SafeAreaView, TouchableOpacity, Text, ScrollView } from 'react-native';
import { AppService } from './src/AppService';
import { IapticRN, IapticSubscriptionView } from 'react-native-iaptic';
import { Config } from './src/Config';

// Create stable references outside component
let iapServiceInstance: AppService | null = null;

function App(): React.JSX.Element {

  // Our interface will reflect the entitlements of the user, so we store them in the state
  const [entitlements, setEntitlements] = useState<string[]>([]);

  // Initialize the iapService, containing our app logic
  const iapService = useRef(
    iapServiceInstance || (iapServiceInstance = new AppService(setEntitlements))
  ).current;

  // One-time initialization with proper cleanup
  useEffect(() => iapService.onAppStartup(), []);

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.productsContainer}>
        <Text style={styles.subscriptionText}>Subscription</Text>

        {/* Basic feature access button */}
        <TouchableOpacity
          onPress={() => iapService.checkFeatureAccess("basic")}
          style={styles.button}
        >
          <Text style={styles.buttonText}>Basic Access: {entitlements.includes('basic') ? 'Granted' : 'Locked'}</Text>
        </TouchableOpacity>

        {/* Premium feature access button */}
        <TouchableOpacity
          onPress={() => iapService.checkFeatureAccess("premium")}
          style={styles.button}
        >
          <Text style={styles.buttonText}>Premium Access: {entitlements.includes('premium') ? 'Granted' : 'Locked'}</Text>
        </TouchableOpacity>

        {/* Subscription management button */}
        <TouchableOpacity
          style={[
            styles.button,
            styles.subscriptionButton,
          ]}
          onPress={() => {
            IapticRN.presentSubscriptionView();
          }}
        >
          <Text style={styles.buttonText}>{!entitlements.includes('basic') ? 'Subscribe To Unlock' : 'Manage Subscription'}</Text>
        </TouchableOpacity>

      </ScrollView>

      {/* This is the IapticSubscriptionView component, which displays the subscription options */}
      <IapticSubscriptionView
        entitlementLabels={Config.entitlements}
        onPurchaseComplete={() => {
          iapService.handlePurchaseComplete();
        }}
        termsUrl={Config.termsUrl}
        theme={{
          primaryColor: '#FF7A00',
          secondaryColor: '#FF0000',
        }}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  productsContainer: {
    padding: 10,
    gap: 10,
    paddingBottom: 20,
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
  },
  restoreText: {
    textAlign: 'center',
    marginTop: 20,
    marginBottom: 10,
    color: '#666',
  },
  subscriptionButton: {
    marginTop: 20,
    backgroundColor: '#5856D6',
  },
  subscriptionText: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#333',
  },
});

export default App;

```

### 5. Running the app

#### For iOS:

During development, you can use sandbox accounts to test IAP:

1. Create a sandbox tester account in App Store Connect
2. Sign out of your regular Apple ID on your device
3. When making a purchase in your app, you'll be prompted to sign in
4. Use your sandbox account credentials
5. Purchases made with sandbox accounts won't incur real charges

#### For Android:

1. Register your testing account in the Google Play Console
2. Sign in to your device with that account
3. Use the test payment method available in development builds

Run the app on your device using:

```bash
npx react-native run-ios
# or
npx react-native run-android
```

You should now be able to:

1. See the locked/unlocked state of features based on your current entitlements
2. Open the subscription view by tapping the "Subscribe To Unlock" button
3. Make purchases through the subscription view
4. Restore previous purchases by tapping "Restore Purchases"
5. See the UI update based on your subscription status

<img src="img/iapui2.png" alt="Subscription view" style="max-width: 300px; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">


[← Previous: Step 5 - Managing Entitlements](tutorial-step5.html) 