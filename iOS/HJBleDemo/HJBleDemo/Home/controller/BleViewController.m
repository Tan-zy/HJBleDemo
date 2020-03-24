//
//  BleViewController.m
//  bleDemo
//
//  Created by wurz on 15/4/14.
//  Copyright (c) 2015年 wurz. All rights reserved.
//

#import "BleViewController.h"
#import "BleSendReceiveTableViewCell.h"
#import <Toast/Toast.h>
#import "SetViewController.h"
#import "HJConfigInfo.h"

@interface BleViewController ()<WWBluetoothLEConnectDelegate>

@property (nonatomic,strong) CBPeripheral *peripheral;

@property (nonatomic, strong) DXMessageToolBar *chatToolBar;

@property (nonatomic, strong) NSMutableArray<BleSendReceiveData *> *tableData;

@property (nonatomic, strong) WWBluetoothLE *ble;

@property (nonatomic, assign) BOOL isShowHex;

@end

@implementation BleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _peripheral = _scanData.peripheral;
    if (!_scanData.isConfig) {
        [HJConfigInfo shareInstance].isBleConfig = false;
    }
    
    UIBarButtonItem *clearBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearData)];

    UIBarButtonItem *setBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"set"] style:UIBarButtonItemStylePlain target:self action:@selector(setBtnClicked)];

    self.navigationItem.rightBarButtonItems = @[setBtnItem, clearBtnItem];
    
    CGFloat chatToolBarHeight = [DXMessageToolBar defaultHeight];
    _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, WW_SCREEN_HEIGHT - [DXMessageToolBar defaultHeight], WW_SCREEN_WIDTH, chatToolBarHeight)];
    _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    _chatToolBar.delegate = self;
    [self.view addSubview:_chatToolBar];
    self.isShowHex = true;
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view).offset(-5-chatToolBarHeight);
        } else {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-5-chatToolBarHeight);
        }
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    
    _tableData = [[NSMutableArray alloc] init];
    
    _ble = [WWBluetoothLE shareBLE];
    _ble.managerDelegate = self;
    _ble.bleDelegate = self;
    _ble.connectDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([HJConfigInfo shareInstance].isBleConfig) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@-配置",_peripheral.name];
    }
    else {
        self.navigationItem.title = [NSString stringWithFormat:@"%@-数据",_peripheral.name];
    }
    
    [self.view endEditing:true];
    [_chatToolBar clearText]; //清空发送的数据
    self.isShowHex = [HJConfigInfo shareInstance].isBleHex;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

// 返回
- (void)leftButtonMethod
{
    [self.navigationController popViewControllerAnimated:YES];
    [_ble disconnect:_peripheral callBack:false];
}

// 清除数据
-(void)clearData
{
    _tableData  = [NSMutableArray array];
    
    [self.tableView reloadData];
}

// 点击设置按钮
- (void)setBtnClicked
{
    SetViewController *setVC = [[SetViewController alloc] init];
    setVC.isBleConfig = _scanData.isConfig;
    [self.navigationController pushViewController:setVC animated:true];
}

//是否显示hex输入
- (void)setIsShowHex:(BOOL)isShowHex
{
    _isShowHex = isShowHex;
    
    if (isShowHex) {
        _chatToolBar.isHex = true;
        _chatToolBar.inputTextView.keyboardType = UIKeyboardTypeASCIICapable;//UIKeyboardTypeNumberPad;
        _chatToolBar.inputTextView.placeHolder = @"请输入Hex数据";
    }
    else {
        _chatToolBar.isHex = false;
        _chatToolBar.inputTextView.keyboardType = UIKeyboardTypeDefault;
        _chatToolBar.inputTextView.placeHolder = @"请输入数据";
    }
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"myCell";
    BleSendReceiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[BleSendReceiveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.bleData = _tableData[indexPath.row];
    //cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (void)keyBoardHidden
{
    [_chatToolBar endEditing:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - DXMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.size.height = self.view.frame.size.height - toHeight;
        self.tableView.frame = rect;
    }];
}

- (void)toolBar:(DXMessageToolBar *)toolBar didSendText:(NSString *)text
{
    [self.view endEditing:true];
    
    if (!text || text.length <= 0) {
        return ;
    }
    
    //hex值，需要输入2的倍数的长度
    if (_isShowHex) {
        
        if (text.length%2 != 0) {
            [self.view makeToast:@"数据不为2的倍数"];
            return;
        }
        
        text = text.uppercaseString;
        
        if (![WWRegexUtils isValidateByRegex:@"^[A-Fa-f0-9]+$" value:text]) {
            [self.view makeToast:@"输入格式错误"];
            return;
        }
    }
    
    BOOL bResult = false;
    
    WWCharacteristic *chart = nil;
    //配置模式
    if ([HJConfigInfo shareInstance].isBleConfig) {
        chart = [HJConfigInfo shareInstance].configSendService;
    }
    else {
        chart = [HJConfigInfo shareInstance].dataSendService;
    }
    
    NSData *sendData = nil;
    if (_isShowHex) {
        NSString *tempText = text;
        if ([HJConfigInfo shareInstance].isAddReturn) {
            tempText = [NSString stringWithFormat:@"%@0D0A", tempText];
        }
        sendData = [NSData stringToHex:tempText];
    }
    else {
        NSString *tempText = text;
        if ([HJConfigInfo shareInstance].isAddReturn) {
            tempText = [NSString stringWithFormat:@"%@\r\n", tempText];
        }
        sendData = [NSData unicodeToUtf8:tempText];
    }
    
    bResult = [_ble send:_peripheral characteristic:chart value:sendData];
    
    if (bResult) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSDate* now = [NSDate date];
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"HH:mm:ss";
        NSString* dateString = [NSString stringWithFormat:@"时间:%@",[fmt stringFromDate:now]];
        [dict setValue:dateString forKey:@"time"];
        [dict setValue:@"发送:" forKey:@"title"];
        [dict setValue:text forKey:@"context"];
        
        [_tableData addObject:[BleSendReceiveData BleSendReceiveDataWithDictionary:dict]];
        [self.tableView reloadData];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_tableData.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        if ([HJConfigInfo shareInstance].isClearInput) {
            [toolBar clearText]; //清空发送的数据
        }
    }
    else {
        [self.view makeToast:@"发送失败"];
    }
    
}

#pragma mark -- WWBluetoothLEManagerDelegate

/**
 *  蓝牙状态，仅在本地蓝牙状态为开启时, 即WWBleLocalStatePowerOn，其他函数方可使用
 *
 *  @param ble     蓝牙
 *  @param state   当前蓝牙的状态
 *
 */
- (void)ble:(WWBluetoothLE *)ble didLocalState:(WWBleLocalState)state
{
    if (state != WWBleLocalStatePowerOn) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSDate* now = [NSDate date];
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"HH:mm:ss";
        NSString* dateString = [NSString stringWithFormat:@"时间:%@",[fmt stringFromDate:now]];
        [dict setValue:dateString forKey:@"time"];
        [dict setValue:@"其他:" forKey:@"title"];
        [dict setValue:@"蓝牙已关闭" forKey:@"context"];
        
        [_tableData addObject:[BleSendReceiveData BleSendReceiveDataWithDictionary:dict]];
        [self.tableView reloadData];
    }
}

#pragma mark -- WWBluetoothLEDelegate

-(void)ble:(WWBluetoothLE *)ble didDisconnect:(CBPeripheral *)peripheral
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSDate* now = [NSDate date];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"HH:mm:ss";
    NSString* dateString = [NSString stringWithFormat:@"时间:%@",[fmt stringFromDate:now]];
    [dict setValue:dateString forKey:@"time"];
    [dict setValue:@"其他:" forKey:@"title"];
    [dict setValue:@"蓝牙已断开" forKey:@"context"];
    
    [_tableData addObject:[BleSendReceiveData BleSendReceiveDataWithDictionary:dict]];
    [self.tableView reloadData];
}

/**
 *  蓝牙发送数据回调
 *
 *  @param ble                  蓝牙
 *  @param peripheral           蓝牙设备
 *  @param characteristic       发送的服务
 *  @param isSuccess            成功true或失败false
 *
 */
- (void)ble:(WWBluetoothLE *)ble didSendData:(CBPeripheral *)peripheral characteristic:(WWCharacteristic *)characteristic result:(BOOL)isSuccess
{
    if (isSuccess) {
        [self.view makeToast:@"发送成功"];
    }
    else{
        [self.view makeToast:@"发送失败"];
    }
}

/**
 *  蓝牙接收数据回调
 *
 *  @param ble                  蓝牙
 *  @param peripheral           蓝牙设备
 *  @param characteristic       接收的服务
 *  @param data                 接收的数据
 *
 */
- (void)ble:(WWBluetoothLE *)ble didReceiveData:(CBPeripheral *)peripheral characteristic:(WWCharacteristic *)characteristic  data:(NSData *)data
{
    WWCharacteristic *currentChara;
    if ([HJConfigInfo shareInstance].isBleConfig) {
        currentChara = [HJConfigInfo shareInstance].configReceiveService;
    }
    else {
        currentChara = [HJConfigInfo shareInstance].dataReceiveService;
    }
    
    // 不接收不是当前模式的回调
    if (![characteristic isEqual:currentChara]) {
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSDate* now = [NSDate date];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"HH:mm:ss";
    NSString* dateString = [NSString stringWithFormat:@"时间:%@",[fmt stringFromDate:now]];
    [dict setValue:dateString forKey:@"time"];
    [dict setValue:@"接收:" forKey:@"title"];
    if (_isShowHex) {
        [dict setValue:[NSString hexToString:data space:NO].uppercaseString forKey:@"context"];
    }
    else {
        [dict setValue:[NSString utf8ToUnicode:data] forKey:@"context"];
    }
    
//    [dict setValue:[NSString utf8ToUnicode:data] forKey:@"context"];
    
    [_tableData addObject:[BleSendReceiveData BleSendReceiveDataWithDictionary:dict]];
    [self.tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_tableData.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

}


@end