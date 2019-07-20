package com.wise.wisekit.activity;

import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.fragment.app.FragmentActivity;

import com.wise.wisekit.R;


/**
 * Created by wuruizhi on 2017/8/16.
 */

public abstract class BaseFragmentActivity extends FragmentActivity {

    protected ImageView topLeftBtn;
    protected ImageView topRightBtn;
    protected TextView topTitleTxt;
    protected ImageView topTitelImage;
    protected TextView letTitleTxt;
    protected ViewGroup topBar;
    protected ViewGroup topContentView;
    protected LinearLayout baseRoot;
    protected LinearLayout topTitleLayout;

    //获取页面布局id
    protected abstract int getPageLayoutId();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        if(Build.VERSION.SDK_INT >= 21) {
            Window window = getWindow();
            //设置修改状态栏
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            //设置状态栏的颜色，和你的app主题或者标题栏颜色设置一致就ok了
            window.setStatusBarColor(getResources().getColor(R.color.colorNavBackground));
        }

        topContentView = (ViewGroup) LayoutInflater.from(this).inflate(
                R.layout.fragment_activity_base, null);
        topBar = (ViewGroup) topContentView.findViewById(R.id.topbar);
        topTitleTxt = (TextView) topContentView.findViewById(R.id.base_activity_title);
        topLeftBtn = (ImageView) topContentView.findViewById(R.id.left_btn);
        topRightBtn = (ImageView) topContentView.findViewById(R.id.right_btn);
        topTitelImage = (ImageView) topContentView.findViewById(R.id.title_image);
        letTitleTxt = (TextView) topContentView.findViewById(R.id.left_txt);
        baseRoot = (LinearLayout)topContentView.findViewById(R.id.act_base_root);
        topTitleLayout = (LinearLayout)topContentView.findViewById(R.id.base_activity_title_layout);

        topTitleTxt.setVisibility(View.GONE);
        topRightBtn.setVisibility(View.GONE);
        letTitleTxt.setVisibility(View.GONE);
        topLeftBtn.setVisibility(View.GONE);
        topTitelImage.setVisibility(View.GONE);

        topLeftBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

        setContentView(topContentView);

        LayoutInflater.from(this).inflate(getPageLayoutId(),topContentView);

        showNavigatorBar(true);

        initView();
    }

    //子类可重载初始化
    protected void initView() {

    }

    //是否显示标题栏，默认显示
    protected void showNavigatorBar(boolean bShow) {
        if (bShow) {
            topContentView.setVisibility(View.VISIBLE);
        }
        else {
            topContentView.setVisibility(View.GONE);
        }
    }

    protected void setLeftText(String text) {
        if (null == text) {
            return;
        }
        letTitleTxt.setText(text);
        letTitleTxt.setVisibility(View.VISIBLE);
    }

    protected void setTitle(String title) {
        if (title == null) {
            return;
        }
        if (title.length() > 12) {
            title = title.substring(0, 11) + "...";
        }
        topTitleTxt.setText(title);
        topTitleTxt.setVisibility(View.VISIBLE);
    }

    @Override
    public void setTitle(int id) {
        String strTitle = getResources().getString(id);
        setTitle(strTitle);
    }

    public void setTitleImage(int resID) {
        if (resID <= 0) {
            return;
        }

        topTitelImage.setImageResource(resID);
        topTitelImage.setVisibility(View.VISIBLE);
    }

    protected void setLeftButton(int resID) {
        if (resID <= 0) {
            return;
        }

        topLeftBtn.setImageResource(resID);
        topLeftBtn.setVisibility(View.VISIBLE);
    }

    protected void setRightButton(int resID) {
        if (resID <= 0) {
            return;
        }

        topRightBtn.setImageResource(resID);
        topRightBtn.setVisibility(View.VISIBLE);
    }

    protected void setTopBar(int resID) {
        if (resID <= 0) {
            return;
        }
        topBar.setBackgroundResource(resID);
    }
}
