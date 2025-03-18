# Integrating In-App Purchases in React Native: Step 4

[← Previous: Step 3 - Configuration](tutorial-step3.html) | [Next: Step 5 - Managing Entitlements →](tutorial-step5.html) 

4# Step 4: In-App Purchase Service Integration

### 1. Create the AppService class

For this tutorial, we'll put our application logic in a separate class called `AppService`.

This class will handle the initialization of the IAP system, and provide methods for checking user entitlements and initiating purchases.

1. Inside the `src` folder, create a new file named `AppService.ts`
2. Let's add the required imports and define our empty `AppService` class for now.

```typescript
import { Platform, Alert, ToastAndroid } from 'react-native';
import { IapticError, IapticSeverity, IapticOffer, IapticRN } from 'react-native-iaptic';
import { Config } from './Config';

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
    console.log(`${new Date().toISOString()} [${severity}] ${message}`);
  }

  /**
   * Creates a new AppService instance
   * @param setEntitlements - Callback function to update UI with current entitlements
   *                          This function is called whenever entitlements change
   */
  constructor(private setEntitlements: (entitlements: string[]) => void) {
  }
}
```

**Constructor**: The setEntitlement function passed to the constructor will let our AppService update the list of entitlements stored in a React state object.

#### What This Code Does:

- **Constructor**: Takes a callback function to update entitlements in the app's UI
- **showAlert()**: Displays alerts when needed
- **log()**: Helper function for logging with severity levels using emojis for visual clarity

### 2. Integrate AppService in App.tsx

Add the following  code to your App.tsx file within your main component function:

```typescript
import React, { useEffect, useState, useRef } from 'react';
import { StyleSheet, SafeAreaView, TouchableOpacity, Text, ScrollView } from 'react-native';

// Add this import
import { AppService } from './src/AppService';

// Create a stable reference to the iapServiceInstance outside the component
let iapServiceInstance: AppService | null = null;

function App(): React.JSX.Element {

  // Our interface will reflect the entitlements of the user, so we store them in the state
  const [entitlements, setEntitlements] = useState<string[]>([]);

  // Initialize the iapService, containing our app logic
  const iapService = useRef<AppService>(
    iapServiceInstance || (iapServiceInstance = new AppService(setEntitlements))
  ).current;
  
  return (
     // ...
```

What This Code Does:

1. `const [entitlements, setEntitlements] = useState<string[]>([]):`
   - Creates a state variable to track user's purchase entitlements (e.g., 'premium', 'pro', 'basic')
   - These entitlements will determine which features the user can access
   - The state variable is used to refresh the UI when entitlements change
   - In large apps, this would be part of your app state.

2. `const iapService = useRef<AppService>(...).current:`
   - Creates a singleton instance of `AppService` that persists between renders
   - Passes the `setEntitlements` function so the service can update the UI when purchases change
   - Uses singleton pattern with `iapServiceInstance` to ensure only one IAP service exists

### 3. App Service Initialization

Now we'll add a function to initialize the IAP system at startup.

```typescript
export class AppService {
  // ... existing code ...
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

  async initializeIaptic() {}
}
```

`onAppStartup()` will initialize the IAP system and provide cleanup when the app closes.

To make sure this is called at startup, we'll add this to our App.tsx file:

```typescript
function App(): React.JSX.Element {
  // ... existing code ...
  // const iapService = ...;

  // One-time initialization with proper cleanup
  useEffect(() => iapService.onAppStartup(), []);

   // ...
```

What this code does:

  - Initializes the IAP service when the app starts
  - The empty dependency array `[]` ensures this only runs once
  - Handles connecting to the app store and loading existing purchases

### 4. Initialize the Iaptic plugin

In our AppService class, let's implement the `initializeIaptic()` function.

```typescript
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
    // This will associate purchases with this user id
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
```

What this code does:

  - Configures event listeners for subscription changes with detailed logging
  - Logs subscription updates with purchase information
  - Initializes the IAP system with the configuration from Config.ts
  - Sets a username for tracking purchases across sessions
  - Updates the UI with current entitlements using the callback function
  - Implements comprehensive error handling with type checking
  - Shows user-friendly alerts with localized messages for different error types

### 5. Complete code

Here's the complete AppService class:

```typescript
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
}
```

Here's the complete App.tsx class:

```typescript
import React, { useEffect, useState, useRef } from 'react';
import { StyleSheet, SafeAreaView, TouchableOpacity, Text, ScrollView } from 'react-native';
import { AppService } from './src/AppService';

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

        {/* A feature that will only be available if the user has any subscription */}
        {/* Currently non-functional - will be connected to IAP service in later steps */}
        <TouchableOpacity
          onPress={() => console.log('Basic access button pressed')}
          style={styles.button}
        >
          <Text style={styles.buttonText}>Basic Access: Locked</Text>
        </TouchableOpacity>

        {/* A feature that will only be available if the user has a premium subscription */}
        {/* Currently non-functional - will be connected to IAP service in later steps */}
        <TouchableOpacity
          onPress={() => console.log('Premium access button pressed')}
          style={styles.button}
        >
          <Text style={styles.buttonText}>Premium Access: Locked</Text>
        </TouchableOpacity>

        {/* Subscription management button */}
        {/* Currently non-functional - will be connected to IAP service in later steps */}
        <TouchableOpacity
          style={[
            styles.button,
            styles.subscriptionButton,
          ]}
          onPress={() => console.log('Subscribe button pressed')}
        >
          <Text style={styles.buttonText}>Subscribe To Unlock</Text>
        </TouchableOpacity>

      </ScrollView>
      {/* In a later step, we'll add the IapticSubscriptionView component here */}
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

**Note:** This code requires the `Config.ts` file with your IAP configuration, which we created in the previous step.

### 6. Running the app
At this point you can run the app on your device. It should initialize the In-app purchase service through loading the products and purchases. But for now you can not make new purchases.

This step helps make sure that the service and configuration are well set up before going further.

### 7. What's Next?

Now that we have created our service layer and understood how to integrate it with our App component, in the next step we'll complete the UI integration by updating our feature buttons to use the AppService methods for checking entitlements and showing the subscription view.

[← Previous: Step 3 - Configuration](tutorial-step3.html) | [Next: Step 5 - Managing Entitlements →](tutorial-step5.html) 