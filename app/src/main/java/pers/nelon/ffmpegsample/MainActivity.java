package pers.nelon.ffmpegsample;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.TextView;

import pers.nelon.library.AhaJni;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);


        TextView viewById = (TextView) findViewById(R.id.tv_info);
        AhaJni ahaJni = new AhaJni();
        viewById.setText(ahaJni.stringFromAha());
    }
}
