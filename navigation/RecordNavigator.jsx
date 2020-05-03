import * as React from 'react';
import { createStackNavigator } from '@react-navigation/stack';

import RecordScreen from'../screens/RecordScreen';

const RecordStack = createStackNavigator();
export default function RecordNavigator({ navigation, options }) {
  navigation.setOptions({
    headerShown: false,
  });

  return (
    <RecordStack.Navigator
      {...options}
    >
      <RecordStack.Screen
        name="Record"
        component={RecordScreen}
      />
    </RecordStack.Navigator>
  );
}