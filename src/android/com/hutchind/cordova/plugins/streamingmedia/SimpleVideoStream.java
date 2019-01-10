package com.hutchind.cordova.plugins.streamingmedia;

import android.app.Activity;
import android.content.res.Configuration;
import android.graphics.Color;
import android.graphics.Point;
import veg.mediaplayer.sdk.MediaPlayer;
import veg.mediaplayer.sdk.MediaPlayerConfig;
import android.widget.MediaController;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.view.MotionEvent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.MediaController;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.VideoView;
import java.nio.ByteBuffer;

public class SimpleVideoStream extends Activity implements MediaPlayer.MediaPlayerCallback {
	private String TAG = getClass().getSimpleName();
	private MediaPlayer mediaPlayer = null;
	private MediaController mMediaController = null;
	private ProgressBar mProgressBar = null;
	private String mVideoUrl;
	private Boolean mShouldAutoClose = true;
	private boolean mControls;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

		Bundle b = getIntent().getExtras();
		mVideoUrl = b.getString("mediaUrl");
		mShouldAutoClose = b.getBoolean("shouldAutoClose", true);
		mControls = b.getBoolean("controls", true);

		RelativeLayout relLayout = new RelativeLayout(this);
		relLayout.setBackgroundColor(Color.BLACK);
		RelativeLayout.LayoutParams relLayoutParam = new RelativeLayout.LayoutParams(
				RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
		relLayoutParam.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
		mediaPlayer = new MediaPlayer(this);
		mediaPlayer.setLayoutParams(relLayoutParam);
		relLayout.addView(mediaPlayer);

		// Create progress throbber
		mProgressBar = new ProgressBar(this);
		mProgressBar.setIndeterminate(true);
		// Center the progress bar
		RelativeLayout.LayoutParams pblp = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT,
				RelativeLayout.LayoutParams.WRAP_CONTENT);
		pblp.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
		mProgressBar.setLayoutParams(pblp);
		// Add progress throbber to view
		relLayout.addView(mProgressBar);
		mProgressBar.bringToFront();

		setOrientation(b.getString("orientation"));

		setContentView(relLayout, relLayoutParam);

		play();
	}

	private void play() {
		mProgressBar.setVisibility(View.VISIBLE);
		try {
			mediaPlayer.getSurfaceView().setZOrderOnTop(true);
			MediaPlayerConfig config = new MediaPlayerConfig();
			config.setConnectionUrl(mVideoUrl);
			config.setConnectionBufferingTime(300);
			config.setConnectionDetectionTime(1000);
			config.setSynchroNeedDropVideoFrames(1);
			config.setDataReceiveTimeout(30000);
			config.setNumberOfCPUCores(0);
			mediaPlayer.Open(config, this);
		} catch (Throwable t) {
			Log.d(TAG, t.toString());
		}
	}

	private void setOrientation(String orientation) {
		if ("landscape".equals(orientation)) {
			this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
		} else if ("portrait".equals(orientation)) {
			this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		}
	}

	private Runnable checkIfPlaying = new Runnable() {
		@Override
		public void run() {
			if (mediaPlayer.getStreamPosition() > 0) {
				// Video is not at the very beginning anymore.
				// Hide the progress bar.
				mProgressBar.setVisibility(View.GONE);
			} else {
				// Video is still at the very beginning.
				// Check again after a small amount of time.
				mediaPlayer.postDelayed(checkIfPlaying, 100);
			}
		}
	};

	@Override
	public void onStart() {
		super.onStart();
		if (mediaPlayer != null)
				mediaPlayer.onStart();
	}

	@Override
	public void onStop() {
		super.onStop();
		if (mediaPlayer != null)
				mediaPlayer.onStop();
	}

	@Override
	public void onPause() {
		super.onPause();
		if (mediaPlayer != null)
				mediaPlayer.onPause();
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
		if (mediaPlayer != null)
				mediaPlayer.Close();
	}

	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
		super.onWindowFocusChanged(hasFocus);
		if (mediaPlayer != null)
				mediaPlayer.onWindowFocusChanged(hasFocus);
	}

	@Override
	public void onLowMemory() {
		super.onLowMemory();
		if (mediaPlayer != null)
				mediaPlayer.onLowMemory();
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		if (mediaPlayer != null)
				mediaPlayer.onDestroy();
	}

	@Override
	public int Status(int i) {
		return 0;
	}

	@Override
	public int OnReceiveData(ByteBuffer byteBuffer, int i, long l) {
		return 0;
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		// The screen size changed or the orientation changed... don't restart the activity
		super.onConfigurationChanged(newConfig);
	}
	
}
