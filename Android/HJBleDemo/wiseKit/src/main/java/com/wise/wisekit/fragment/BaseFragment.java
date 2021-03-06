package com.wise.wisekit.fragment;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.fragment.app.Fragment;

import com.wise.wisekit.R;


/**
 * Created by wuruizhi on 2017/8/12.
 */

public abstract class BaseFragment extends Fragment {

    public String TAG =  this.getClass().getCanonicalName();

    protected ImageView topLeftBtn;
    protected ImageView topRightBtn;
    protected ImageView topTitelImage;
    protected TextView topTitleTxt;
    protected TextView leftTitleTxt;
    protected TextView rightTitleTxt;
    protected ViewGroup topBar;
    protected ViewGroup topContentView;
    protected LinearLayout baseRoot;
    protected View separateLineView; //分割线

    protected View currentView;

    //获取页面布局id
    protected abstract int getPageLayoutId();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        topContentView = (ViewGroup) inflater.inflate(R.layout.fragment_base, null);
        topBar = (ViewGroup) topContentView.findViewById(R.id.topbar);
        topTitleTxt = (TextView) topContentView.findViewById(R.id.base_activity_title);
        topLeftBtn = (ImageView) topContentView.findViewById(R.id.left_btn);
        topRightBtn = (ImageView) topContentView.findViewById(R.id.right_btn);
        topTitelImage = (ImageView) topContentView.findViewById(R.id.title_image);
        leftTitleTxt = (TextView) topContentView.findViewById(R.id.left_txt);
        rightTitleTxt = (TextView) topContentView.findViewById(R.id.right_txt);
        baseRoot = (LinearLayout)topContentView.findViewById(R.id.act_base_root);
        separateLineView = topContentView.findViewById(R.id.separate_line);

        topTitleTxt.setVisibility(View.GONE);
        topRightBtn.setVisibility(View.GONE);
        leftTitleTxt.setVisibility(View.GONE);
        rightTitleTxt.setVisibility(View.GONE);
        topLeftBtn.setVisibility(View.GONE);
        topTitelImage.setVisibility(View.GONE);

        currentView = inflater.inflate(getPageLayoutId(), topContentView);

        initView();

        return currentView;
    }

    //子类可重载初始化
    protected void initView() {

    }

    public void willShowFragment(){

    }

    public void willHideFragment(){

    }

//    public void onResume() {
//
//    }
//
//    public void onPause() {
//
//    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
    }

    protected void setLeftText(String text) {
        if (null == text) {
            return;
        }
        leftTitleTxt.setText(text);
        leftTitleTxt.setVisibility(View.VISIBLE);
    }

    protected void setRightText(String text) {
        if (null == text) {
            return;
        }
        rightTitleTxt.setText(text);
        rightTitleTxt.setVisibility(View.VISIBLE);
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
