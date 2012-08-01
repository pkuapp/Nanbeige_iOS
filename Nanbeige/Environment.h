/*
 *  Environment.h
 *  iOSOne
 *
 *  Created by wuhaotian on 11-6-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#define iOSVersionNum 90
#define url_iOS_version @"http://www.pkucada.org:8082/Server/app/iOS_version"

#define urlImgDean @"http://dean.pku.edu.cn/student/yanzheng.php?act=init"
#define urlImgEle @"http://elective.pku.edu.cn/elective2008/DrawServlet?Rand=1898"

#define urlLoginDean @"http://www.pkucada.org:8082/Server/login"
#define urlLoginEle @"http://www.pkucada.org:8082/Server/login_elective"

#define urlUpdateLocation @"http://www.pkucada.org:8082/Server/classroom/jsonlocation"
#define urlProfile @"http://www.pkucada.org:8082/Server/account/jsonprofile"
#define urlCourse @"http://www.pkucada.org:8082/Server/account/jsonmycourse"
#define urlClassroom [NSURL URLWithString: @"http://www.pkucada.org:8082/Server/classroom/json"]
#define urlCourseAll @"http://www.pkucada.org:8082/Server/course/all"
#define urlCourseCategory @"http://www.pkucada.org:8082/Server/course/category"

#define urlAPIUserLoginEmail [NSURL URLWithString:@"http://api.pkuapp.com:333/user/login/email/"]
#define urlAPIUserRegEmail [NSURL URLWithString:@"http://api.pkuapp.com:333/user/reg/email/"]
#define urlAPIUserEdit [NSURL URLWithString:@"http://api.pkuapp.com:333/user/edit/"]
#define kAPIEMAIL @"email"
#define kAPIPASSWORD @"password"
#define kAPINICKNAME @"nickname"
#define kAPIERROR @"error"
#define kAPIUNIVERSITY @"university"
#define kAPIUNIVERSITY_ID @"university_id"
#define kAPIWEIBO_TOKEN @"weibo_token"
#define urlAPICourse [NSURL URLWithString:@"http://api.pkuapp.com:333/course/"]
#define urlAPIUniversity [NSURL URLWithString:@"http://api.pkuapp.com:333/university/"]
#define kAPIID @"id"
#define kAPIName @"name"

#define pathLocation [NSHomeDirectory() stringByAppendingString:@"/Documents/location.plist"]
#define pathUserPlist [NSHomeDirectory() stringByAppendingString:@"/Documents/User.plist"]
#define pathClassroomQueryCache [NSHomeDirectory() stringByAppendingString:@"/Documents/ClassroomQueryCache.plist"]
#define pathsql2 [NSHomeDirectory() stringByAppendingString:@"/Documents/coredata2.sqlite"]
#define pathSQLCore [NSHomeDirectory() stringByAppendingString:@"/Documents/coredata.sqlite"]
#define VersionReLogin 3
//Global Color here. Will move to other place in future build
//#define navigationBgColor nil //[[UIColor alloc] initWithRed:228/255.0 green:231/255.0 blue:233/255.0 alpha:1.0]

#define TITLE_MAIN @"仪表盘"
#define TITLE_STREAM @"信息流"
#define TITLE_SETTINGS @"设置"
#define TITLE_ABOUT @"关于南北阁"
#define TITLE_ITS @"IP网关"
#define TITLE_ASSIGNMENT @"作业"

//#define tableBgColor [[UIColor alloc] initWithRed:239/255.0 green:234/255.0 blue:222/255.0 alpha:1.0]
//#define navBarBgColor [[UIColor alloc] initWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0]
#define labelLeftColor [[UIColor alloc] initWithRed:0/255.0 green:114/255.0 blue:225/255.0 alpha:1.0]
#define tableBgColor1 [[UIColor alloc] initWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0]
#define tableBgColor2 [[UIColor alloc] initWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]
#define navBarBgColor1 [[UIColor alloc] initWithRed:110/255.0 green:110/255.0 blue:110/255.0 alpha:1.0]
#define gateConnectingBtnColor [[UIColor alloc] initWithRed:255/255.0 green:248/255.0 blue:176/255.0 alpha:1.0]
#define gateConnectedBtnColor [[UIColor alloc] initWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0]

#define gateConnectCellColor [UIColor colorWithRed:80/255.0 green:160/255.0 blue:90/255.0 alpha:1.0]
#define gateDisconnectCellColor [UIColor colorWithRed:176/255.0 green:92/255.0 blue:69/255.0 alpha:1.0]

#define notCompleteAssignmentCellColor [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0]
#define completeAssignmentCellColor [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0]

#define kMAINORDERKEY @"mainorder"
#define kWEIBOIDKEY @"weiboid"
#define kWEIBONAMEKEY @"weiboname"
#define kWEIBOTOKENKEY @"weibo_token"
#define kRENRENIDKEY @"renrenid"
#define kRENRENNAMEKEY @"renrenname"
#define kRENRENTOKENKEY @"renren_token"
#define kITSIDKEY @"itsid"
#define kITSPASSWORDKEY @"itspassword"

#define kACCOUNTIDKEY @"accoundid"
#define kACCOUNTPASSWORDKEY @"accoundpassword"
#define kACCOUNTEDIT @"accountedit"
#define kACCOUNTEDITUNIVERSITY_ID @"accountedituniversity_id"
#define kACCOUNTEDITWEIBO_TOKEN @"accounteditweibo_token"
#define kACCOUNTEDITNICKNAME @"accounteditnickname"
#define kACCOUNTEDITPASSWORD @"accounteditpassword"

#define kUNIVERSITYID @"universityid"
#define kUNIVERSITYNAME @"universityname"

#define kNANBEIGEEMAILKEY @"nanbeigeemail"
#define kNANBEIGEPASSWORDKEY @"nanbeigepassword"
#define kNANBEIGEIDKEY @"nanbeigeid"
#define kNANBEIGENICKNAME @"nickname"

#define kASSIGNMENTS @"assignments"
#define kCOMPLETEASSIGNMENTS @"complete_assignments"
#define kASSIGNMENTHASIMAGE @"assignment_hasimage"
#define kASSIGNMENTIMAGE @"assignment_image"
#define kASSIGNMENTCOURSE @"assignment_course"
#define kASSIGNMENTDESCRIPTION @"assignment_description"
#define kASSIGNMENTCOMPLETE @"assignment_complete"

#define kASSIGNMENTDDLSTR @"assignment_ddl_str"
#define kASSIGNMENTDDLMODE @"assignment_ddl_mode"
#define kASSIGNMENTDDLDATE @"assignment_ddl_date"
#define kASSIGNMENTDDLWEEKS @"assignment_ddl_weeks"
#define ONCLASS 0
#define ONDATE 1
#define NOTCOMPLETE 0
#define COMPLETE 1

#define kSTREAMTITLE @"name"
#define kSTREAMDETAIL @"credit"

#define kCOURSES @"courses"

#define ASSIGNMENTDDLWEAKS [[NSArray alloc] initWithObjects:@"本周", @"下周", @"2周后", @"3周后", @"4周后", @"5周后", @"6周后", @"7周后", @"8周后", @"9周后", @"10周后", @"11周后", @"12周后", @"13周后", @"14周后", @"15周后", @"16周后", @"17周后", @"18周后", @"19周后", @"20周后", @"26周后", @"52周后", @"猴年马月", nil];
#define TEMPCOURSES [[NSArray alloc] initWithObjects:@"毛概", @"地概", @"信概", @"计概", nil];

///////////////////////////////
#define test_username @"pkttus#42$"

#define ChooseLoginTableViewHeaders @[@"登录南北阁",@"也可使用"]
#define ChooseLoginTableViewValues @[@[@"人人网", @"新浪微博"],@[@"Email地址"]]
#define ChooseLoginTableViewSelectSegues @[@[@"EmailLoginSegue",@"EmailLoginSegue"],@[@"EmailLoginSegue"]]
