package com.example.airpolproject;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }

    //when clicked on camera icon, move to its activity and show its layout
    public void onCameraClick(View v){
        Intent myIntent = new Intent(getBaseContext(),   Main2Activity.class);
        startActivity(myIntent);
    }
}
