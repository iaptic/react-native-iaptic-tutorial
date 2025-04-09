# Integrating In-App Purchases in React Native: Step 1

[Next: Step 2 - Installing Iaptic →](tutorial-step2.html)

## Prerequisites

Before you begin this tutorial, make sure you have the following:

- Node.js (v14 or newer) and npm installed
- React Native development environment set up (0.78 and 0.76.5 tested)
- Xcode installed (for iOS development)
- Android Studio installed (for Android development)
- Basic knowledge of React Native and TypeScript
- An Apple Developer account (for testing on iOS)
- A Google Play Developer account (for testing on Android)

## Introduction

This tutorial will guide you through integrating in-app purchases (IAP) into a React Native application using the react-native-iaptic library. Our library works with the React Native CLI. If you are using Expo, you should eject from it to be able to integrate the library.

The react-native-iaptic library provides a simple integration and a built-in subscription management screen. Using the simple integration, you do not need to create screens to manage the subscription process, you only have to configure your information. The end result looks like the following:

<img src="img/iapui2.png" alt="Subscription view" style="max-width: 300px; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">

We'll take a step-by-step approach, starting with a basic UI and progressively adding IAP functionality.

## Step 1: Creating the Basic UI Structure

In this first step, we'll create the basic UI structure for our application. This includes buttons for accessing features that will later be locked behind subscriptions, and a button to open the subscription management screen.

<img src="img/buttons.png" alt="App with subscription buttons" style="max-width: 300px; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">

### 1. Create a New React Native Project

If you haven't already, create a new React Native project:

```bash
npx react-native init IAPDemoApp
cd IAPDemoApp
```

### 2. Update the App.tsx File

Replace the contents of the `App.tsx` file with the following code. This code will only display buttons that will be locked/unlocked based on the user's subscription status in later steps, in addition to a button that will open the subscription management screen:

```typescript
/* App.tsx file */

import React from 'react';
import { StyleSheet, SafeAreaView, TouchableOpacity, Text, ScrollView } from 'react-native';

/**
 * Main App Component
 * 
 * This is Step 1 of our tutorial - creating the basic UI structure
 * At this point, the buttons don't actually do anything when pressed
 */
function App(): React.JSX.Element {

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

### 3. Explanation of the Code

Let's break down what this code does:

- **App** Component: This is the main component that renders our app UI.
- **UI Elements**:
  - A header text labeled "Subscription"
  - Two feature access buttons ("Basic Access" and "Premium Access") that will be locked/unlocked based on the user's subscription status in later steps
  - A subscription button that will open the subscription view
- **Placeholder Functionality**: Currently, the buttons only log messages to the console. In the next steps, we'll connect them to the IAP functionality.

### 4. Run the App

Let's run the app to see our UI:

```bash
npx react-native run-ios
# or for Android
npx react-native run-android
```

### 5. What You Should See

You should now see an app with:

<img src="img/buttons.png" alt="App with subscription buttons" style="max-width: 300px; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">

If you tap any of these buttons, they'll only log messages to the console for now.

## Next Steps

In the next step, we'll:

- Install the react-native-iaptic library
- Create a configuration file for our in-app purchases
- Set up the service layer to handle IAP interactions

Continue to [Step 2: Installing the React Native Iaptic Package](tutorial-step2.html) to proceed with the tutorial.

[Next: Step 2 - Installing Iaptic →](tutorial-step2.html) 