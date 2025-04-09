# Integrating In-App Purchases in React Native: Step 5

[← Previous: Step 4 - Service Layer](tutorial-step4.html) | [Next: Step 6 - Making Purchases →](tutorial-step6.html)

## Step 5: Managing Entitlements

Now, let's start the serious stuff. 

### 1. Check the entitlements

Let's create the appropriate feedback when the user presses on a button related to a feature. We will add a function in the `AppService.ts` file that checks whether the user has the related entitlement:

```typescript
/* AppService.ts file */

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
```

#### Update the App.tsx Class

Now, let's connect our UI blue buttons to the `checkFeatureAccess` method. Change the code of your feature buttons in `App.tsx` to call this method when pressed:

```typescript
/* App.tsx file */

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
```

This approach provides several benefits:

1. **Declarative UI**: The button text is dynamically updated based on the current entitlements state
2. **Centralized logic**: All entitlement checking is handled in one place in the AppService, making the code more maintainable
3. **Direct user feedback**: When users tap a feature button, they immediately receive feedback about whether they have access to that feature
4. **Subscription prompting**: For locked features, users are prompted to subscribe, guiding them toward conversion

### 6. Running the Complete App

Run the app on your device using:

```bash
npx react-native run-ios
# or
npx react-native run-android
```

You should now be able to:

1. See the locked/unlocked state of features based on your current entitlements

<img src="img/alert.png" alt="Subscription view" style="max-width: 300px; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">

### 3. What's Next?

Now that we've set up feature access checking and connected it to our UI, the next step is implementing the actual purchase functionality. In the next step, we'll learn how to display subscription options and handle the purchase flow.

[← Previous: Step 4 - Service Layer](tutorial-step4.html) | [Next: Step 6 - Making Purchases →](tutorial-step6.html) 