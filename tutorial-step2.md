# Integrating In-App Purchases in React Native: Step 2

[← Previous: Step 1 - Creating the UI](tutorial-step1.html) | [Next: Step 3 - Configuration →](tutorial-step3.html)

## Step 2: Installing the React Native Iaptic Package

Now that we have our basic UI structure in place, it's time to install the react-native-iaptic package. This library will provide all the functionality needed to implement in-app purchases in our React Native application.

### 1. Install the Packages

First, navigate to your project directory if you're not already there:

```bash
cd IAPDemoApp
```

Next, install the react-native-iap package using npm:

```bash
npm install --save react-native-iap
```

Then, install the react-native-iaptic package using npm:

```bash
npm install --save react-native-iaptic
```

### 2. Install Pod Dependencies (iOS)

If you're developing for iOS, you need to install the CocoaPods dependencies:

```bash
cd ios
pod install
cd ..
```

### 3. Verify Installation

You can verify that the package was installed correctly by checking your package.json file:

On the terminal:
```bash
grep -C3 react-native-iaptic package.json
```

Or using that search in your IDE `react-native-iaptic`.

You should see something like:

```json
"dependencies": {
  // ... other dependencies
  "react-native-iaptic": "^x.y.z"
}
```

Where x.y.z is the version number of the plugin.

### 4. What's Next?

Now that we've installed the react-native-iaptic package, in the next step we'll create the configuration file for our in-app purchases. This file will define the products we want to offer and the entitlements associated with them.

Continue to [Step 3: Creating the Configuration File](tutorial-step3.html) to proceed with the tutorial.

[← Previous: Step 1 - Creating the UI](tutorial-step1.html) | [Next: Step 3 - Configuration →](tutorial-step3.html) 