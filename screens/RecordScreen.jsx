
import * as WebBrowser from 'expo-web-browser';
import * as React from 'react';
import { Image, Button, Platform, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { ScrollView } from 'react-native-gesture-handler';

import { MonoText } from '../components/StyledText';

export default function HomeScreen({navigation}) {
    return (
        <View>
            <Text>Record your emotion</Text>
            <Button
                title='Cancel'
                color='red'
                onPress={() => navigation.goBack()}
            />
        </View>
    );
}