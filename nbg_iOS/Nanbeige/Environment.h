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

#define DEFAULT_TIMEOUT 20
#define urlAPIUserLoginEmail [NSURL URLWithString:@"http://api.pkuapp.com:333/user/login/email/"]
#define urlAPIUserLoginWeibo [NSURL URLWithString:@"http://api.pkuapp.com:333/user/login/weibo/"]
#define urlAPIUserLoginRenren [NSURL URLWithString:@"http://api.pkuapp.com:333/user/login/renren/"]
#define urlAPIUserLogout [NSURL URLWithString:@"http://api.pkuapp.com:333/user/logout/"]
#define urlAPIUserRegEmail [NSURL URLWithString:@"http://api.pkuapp.com:333/user/reg/email/"]
#define urlAPIUserRegWeibo [NSURL URLWithString:@"http://api.pkuapp.com:333/user/reg/weibo/"]
#define urlAPIUserRegRenren [NSURL URLWithString:@"http://api.pkuapp.com:333/user/reg/renren/"]
#define urlAPIUserEdit [NSURL URLWithString:@"http://api.pkuapp.com:333/user/edit/"]
#define urlAPIUniversity [NSURL URLWithString:@"http://api.pkuapp.com:333/university/"]
#define urlAPIStudyBuildingWithCampus_ID(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/study/building/?campus_id=%@", (id)]]
#define urlAPIStudyBuildingRoomWithBuilding_ID(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/study/building/%@/room/", (id)]]
#define urlAPIStudyBuildingRoomWithBuilding_IDAndDate(id,date) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/study/building/%@/room/?date=%@", (id), (date)]]
#define urlAPICourse [NSURL URLWithString:@"http://api.pkuapp.com:333/course/"]
#define urlAPICourseGrabber [NSURL URLWithString:@"http://api.pkuapp.com:333/course/grabber/"]
#define urlAPICourseGrabberCaptcha [NSURL URLWithString:@"http://api.pkuapp.com:333/course/grabber/captcha/"]
#define urlAPICourseGrabberStart [NSURL URLWithString:@"http://api.pkuapp.com:333/course/grabber/start/"]
#define urlAPICourseCommentWithCourse_ID(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/course/%@/comment/", (id)]]
#define urlAPICourseCommentAddWithCourse_ID(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/course/%@/comment/add/", (id)]]
#define urlAPICourseAssignment [NSURL URLWithString:@"http://api.pkuapp.com:333/course/assignment/"]
#define urlAPICourseAssignmentFinishWithID(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/course/assignment/%@/finish/", (id)]]
#define urlAPICourseAssignmentDeleteWithID(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/course/assignment/%@/delete/", (id)]]
#define urlAPICourseAssignmentModifyWithID(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/course/assignment/%@/modify/", (id)]]
#define urlAPICourseAssignmentAdd [NSURL URLWithString:@"http://api.pkuapp.com:333/course/assignment/add/"]
#define urlAPIEvent [NSURL URLWithString:@"http://api.pkuapp.com:333/event/"]
#define urlAPIEventCategory [NSURL URLWithString:@"http://api.pkuapp.com:333/event/category/"]
#define urlAPIEventWithID(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/event/%@/", (id)]]
#define urlAPIEventFollowWithID(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pkuapp.com:333/event/%@/follow/", (id)]]
#define urlAPIEventFollowing [NSURL URLWithString:@"http://api.pkuapp.com:333/event/following/"]

#define kAPIEMAIL @"email"
#define kAPIUSERNAME @"username"
#define kAPIPASSWORD @"password"
#define kAPICAPTCHA @"captcha"
#define kAPINICKNAME @"nickname"
#define kAPIERROR @"error"
#define kAPIERROR_CODE @"error_code"
#define kAPIUNIVERSITY @"university"
#define kAPICAMPUS @"campus"
#define kAPICAMPUS_ID @"campus_id"
#define kAPICAMPUSES @"campuses"
#define kAPIWEIBO_TOKEN @"weibo_token"
#define kAPICOURSE_IMPORTED @"course_imported"
#define kAPIID @"id"
#define kAPINAME @"name"
#define kAPITOKEN @"token"
#define kAPISCREEN_NAME @"screen_name"
#define kAPISTATUSES @"statuses"
#define kAPICOUNT @"count"
#define kAPIMORNING @"morning"
#define kAPIAFTERNOON @"afternoon"
#define kAPIEVENING @"evening"
#define kAPITOTAL @"total"
#define kAPIDETAIL @"detail"
#define kAPISTART @"start"
#define kAPIEND @"end"
#define kAPINUMBER @"number"
#define kAPISEPARATORS @"separators"
#define kAPICREDIT @"credit"
#define kAPILESSONS @"lessons"
#define kAPIDAY @"day"
#define kAPILOCATION @"location"
#define kAPIWEEK @"week"
#define kAPIWEEKS @"weeks"
#define kAPIORIG_ID @"orig_id"
#define kAPISEMESTER_ID @"semester_id"
#define kAPITA @"ta"
#define kAPITEACHER @"teacher"
#define kAPIAVAILABLE @"available"
#define kAPIREQUIRE_CAPTCHA @"require_captcha"
#define kAPIFINISHED @"finished"
#define kAPICOURSE_ID @"course_id"
#define kAPIDUE @"due"
#define kAPICONTENT @"content"
#define kAPIKEYWORD @"keyword"
#define kAPICATEGORY_ID @"category_id"
#define kAPIAFTER @"after"
#define kAPIBEFORE @"before"

#define sERRORAUTHERROR @"AuthError"
#define sERRORCAPTCHAERROR @"CaptchaError"
#define sERRORUNKNOWNERROR @"UnknownError"
#define sERRORUSERNOTFOUND @"UserNotFound"

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
#define TITLE_SELECTED_COURSE @"我的课程"
#define FORMAT_TITLE_ROOMS @"教学楼・%@"
#define LIMIT_ROOM_STRING_LENGTH 20

//#define tableBgColor [[UIColor alloc] initWithRed:239/255.0 green:234/255.0 blue:222/255.0 alpha:1.0]
//#define navBarBgColor [[UIColor alloc] initWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0]
#define labelLeftColor [[UIColor alloc] initWithRed:0/255.0 green:114/255.0 blue:225/255.0 alpha:1.0]
#define tableBgColor1 [[UIColor alloc] initWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0]
#define tableBgColor2 [[UIColor alloc] initWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0]
#define tableBgColor3 [[UIColor alloc] initWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0]
#define tableBgColor4 [[UIColor alloc] initWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]
#define navBarBgColor1 [[UIColor alloc] initWithRed:225/255.0 green:220/255.0 blue:0/255.0 alpha:1.0]
#define tabBarBgColor1 [[UIColor alloc] initWithRed:55/255.0 green:119/255.0 blue:138/255.0 alpha:1.0]
#define separatorColor1 [[UIColor alloc] initWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0]
#define separatorColor2 [[UIColor alloc] initWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]
#define separatorColor3 [[UIColor alloc] initWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0]
#define separatorColor4 [[UIColor alloc] initWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]
#define separatorColor5 [[UIColor alloc] initWithRed:138/255.0 green:138/255.0 blue:138/255.0 alpha:1.0]
#define separatorColor6 [[UIColor alloc] initWithRed:168/255.0 green:168/255.0 blue:168/255.0 alpha:1.0]
#define timeColor1 [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0]
#define gateConnectingBtnColor [[UIColor alloc] initWithRed:255/255.0 green:248/255.0 blue:176/255.0 alpha:1.0]
#define gateConnectedBtnColor [[UIColor alloc] initWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0]

#define gateConnectCellColor [UIColor colorWithRed:80/255.0 green:160/255.0 blue:90/255.0 alpha:1.0]
#define gateDisconnectCellColor [UIColor colorWithRed:176/255.0 green:92/255.0 blue:69/255.0 alpha:1.0]

#define notCompleteAssignmentCellColor [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0]
#define completeAssignmentCellColor [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0]

#define kMAINORDERKEY @"mainorder"
#define kCOURSE_IMPORTED @"course_imported"

#define kWEIBOIDKEY @"weiboid"
#define kWEIBONAMEKEY @"weiboname"
#define kWEIBOTOKENKEY @"weibo_token"
#define kRENRENIDKEY @"renrenid"
#define kRENRENNAMEKEY @"renrenname"
#define kRENRENTOKENKEY @"renren_token"
#define kITSIDKEY @"itsid"
#define kITSPASSWORDKEY @"itspassword"

#define kACCOUNTIDKEY @"accoundid"
#define kACCOUNTNICKNAMEKEY @"accountnickname"
#define kACCOUNTEDIT @"accountedit"
#define kACCOUNTEDITCAMPUS_ID @"accounteditcampus_id"
#define kACCOUNTEDITWEIBO_TOKEN @"accounteditweibo_token"
#define kACCOUNTEDITNICKNAME @"accounteditnickname"
#define kACCOUNTEDITPASSWORD @"accounteditpassword"

#define kUNIVERSITYIDKEY @"universityid"
#define kUNIVERSITYNAMEKEY @"universityname"
#define kCAMPUSNAMEKEY @"campusname"
#define kCAMPUSIDKEY @"campusid"

#define kCPEMAILKEY @"CPemail"
#define kCPPASSWORDKEY @"CPpassword"
#define kCPIDKEY @"CPid"
#define kCPNICKNAMEKEY @"nickname"

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

#define TIMETABLEPAGEGAPWIDTH 16.0f
#define TIMETABLEPAGENUMBER 9999
#define TIMETABLEPAGEINDEX 4999
#define TIMETABLEHEIGHT 367
#define TIMETABLEWIDTH 320
#define TIMETABLELEFTPADDING 30
#define TIMETABLESEPARATORHEIGHT 1
#define kSHOWTIME @"showtime"

#define ASSIGNMENTDDLWEAKS [[NSArray alloc] initWithObjects:@"本周", @"下周", @"2周后", @"3周后", @"4周后", @"5周后", @"6周后", @"7周后", @"8周后", @"9周后", @"10周后", @"11周后", @"12周后", @"13周后", @"14周后", @"15周后", @"16周后", @"17周后", @"18周后", @"19周后", @"20周后", @"26周后", @"52周后", @"猴年马月", nil];
#define kTEMPCOURSES @"tempcourses"
#define kTEMPUNIVERSITIES @"tempuniversities"
#define kTEMPUNIVERSITY @"tempuniversity"
#define kTEMPBUILDINGS @"tempbuildings"
#define kTEMPROOMS @"temprooms"

#define kTEMPSTREAMS @"tempstreams"
#define kSTREAMTITLE @"text"
#define kSTREAMDETAIL @"user"
#define kSTREAMDETAILMORE @"screen_name"

///////////////////////////////
#define test_username @"pkttus#42$"



#define sRENREN @"人人网"
#define sWEIBO @"新浪微博"
#define sEMAIL @"Email"
#define sLOGOUT @"登出"
#define sNICKNAME @"昵称"
#define sUNIVERSITY @"学校"
#define sDEFAULTNICKNAME @"未命名"
#define sDEFAULTUNIVERSITY @"未选校"
#define sEDITPASSWORD @"修改密码"
#define sEDITNICKNAME @"修改昵称"
#define sCONFIRM @"确认"
#define sCANCEL @"取消"
#define sCONNECTRENREN [@"连接到" stringByAppendingString:sRENREN]
#define sCONNECTWEIBO [@"连接到" stringByAppendingString:sWEIBO]
#define sCONNECTEMAIL [@"绑定" stringByAppendingString:sEMAIL]
#define sDISCONNECTRENREN [NSString stringWithFormat:@"断开%@连接", sRENREN]
#define sDISCONNECTWEIBO [NSString stringWithFormat:@"断开%@连接", sWEIBO]
#define sDISCONNECTEMAIL [NSString stringWithFormat:@"取消%@绑定", sEMAIL]

#define dictLABEL2CONNECT @{sCONNECTRENREN:@"onRenrenLogin:", sCONNECTWEIBO:@"onWeiboLogin:", sCONNECTEMAIL:@"onEmailLogin:"}
#define dictLABEL2ACTIONSHEET @{sLOGOUT:sLOGOUT, sEMAIL:sDISCONNECTEMAIL, sRENREN:sDISCONNECTRENREN, sWEIBO:sDISCONNECTWEIBO}
#define dictACTIONSHEET2DISCONNECT @{sLOGOUT:@1, sDISCONNECTEMAIL:@2, sDISCONNECTRENREN:@3, sDISCONNECTWEIBO:@4, sEDITPASSWORD:@5, sEDITNICKNAME:@6}
