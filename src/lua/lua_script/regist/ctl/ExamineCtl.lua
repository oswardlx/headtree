--
-- Created by IntelliJ IDEA.
-- User: osward
-- Date: 2017/11/16
-- Time: 10:15
-- To change this template use File | Settings | File Templates.
--
local uri = ngx.var.uri
--local test1  = require("requiretest")
local web = require("social.router.router")
local request = require("social.common.request")
local _util  = require "new_base.util"
local permission_context = ngx.var.path_uri --有权限的context.
local permission_no_context =  ngx.var.path_uri_no_permission
local ssdb_dao = require("space.course_package.dao.CoursePackageSSDBDao");
local _PersonInfo = require("space.services.PersonAndOrgBaseInfoService")

local cjson = require "cjson"
local log = require("social.common.log4j"):new()
local service = require("space.examine.service.ExamineService")
local TS = require "resty.TS"
local function demo1()
--    local person_id = request:getNumParam("person_id",true,true)
--    local identity_id request:getNumParam("identity_id",true,true)
----    local person_res = _util:getPersonInfoByPersonId(person_id)
--    local school_name =_PersonInfo:getSchoolNameAndClassNameByPersonId(person_id,identity_id)
--log:debug(school_name)
--    ngx.say(cjson.encode(school_name))
--    local org_id = request:getNumParam('org_id',true,true)
--    local data = ngx.location.capture("/dsideal_yy/management/sys/org/getEduUnitByOrgId?org_id="..org_id)
--    local _data;
--    if data.status ==200 then
--        _data = cjson.decode(data.body)
--        log:debug(_data)
--        log:debug(_data['ORG_NAME'])
--        local org_name = _data['ORG_NAME']
--        if org_name then
--            return org_name
--        else
--            return "获取学校名字失败"
--        end
--
-- end
    local org_id = request:getNumParam('org_id',true,true)
    local aService = require "space.services.PersonAndOrgBaseInfoService"
    local school = aService:getSchoolInfo(org_id);
    ngx.say(school.school_name)
    return;
end

--增加单个审批人员
local function addExaminaPerson()
    local person_id = request:getNumParam("person_id", true, true) --
    local level = request:getNumParam("level", true, true) --
    local identity_id = request:getNumParam("identity_id", true, true) --
    local person_name = request:getStrParam("person_name", true, true)
    local dept_id = request:getNumParam("dept_id", false, false) --

    local office_id = request:getNumParam("office_id",false,false)
    local org_id = request:getNumParam("org_id", true, true) --
    local org_type = request:getNumParam("org_type", true, true) --
    local result, id = service.addExaminaPerson({
        person_id = person_id,
        identity_id=identity_id,
        level = level,
        person_name=person_name,
        dept_id = dept_id,
        org_id = org_id,
        org_type = org_type,
        office_id = office_id,
    });
    if not result or result==false then
--
        ngx.say(cjson.encode({ success = result,info ="重复添加人员，或操作有误" }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end

--批量增加审批人员
local function addExaminaPersons()
    local personList = request:getStrParam("personList",true,true)

    personList = cjson.decode(personList)
    local result = service.addExaminaPersons(personList)
    if  not result or result==false then
        ngx.say(cjson.encode({ success = false,info = '重复添加，或者操作有误' }))
        return;
    end

    ngx.say(cjson.encode({ success = true}))
    return;
end

--删除单个审批人员
local function removeExaminaPerson()
    local id = request:getNumParam("id", true, true) --

    local result, id = service.removeExaminaPerson(id);
    if not result then
        ngx.say(cjson.encode({ success = result }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end

--获得教育局某科室的所有审批人员
local function findExaminaDeptPerson()


    local office_id= request:getNumParam("office_id", true, true) --
    local  resultInfo = service.findExaminaDeptPerson(office_id);
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo }))
    return;
end

--获得校长级或者局长级或财务审批人员的信息
local function findExaminaExDeptPerson()
    local level= request:getNumParam("level", true, true) --
    local org_id= request:getNumParam("org_id", true, true) --
    local org_type= request:getNumParam("org_type", true, true) --
    local  resultInfo = service.findExaminaExDeptPerson(level,org_id,org_type);
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo }))
    return;
end




--增加单个科室
local function addExaminaOffice()
    local office_name = request:getStrParam("office_name", false, false)
    local org_id = request:getNumParam("org_id", true, true) --
    local org_type = request:getNumParam("org_type", true, true) --
    local dept_id = request:getNumParam("dept_id",true,true)
    local result, id = service.addExaminaOffice({
        office_name = office_name,
        org_id = org_id,
        org_type = org_type,
        dept_id = dept_id
    });
    if not result then
        ngx.say(cjson.encode({ success = result }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))


    return;


end

--删除单个科室
local function removeExaminaOffice()
    local office_id = request:getNumParam("office_id", true, true) --

    local result, id = service.removeExaminaOffice(office_id);
    if not result then
        ngx.say(cjson.encode({ success = result }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end

--获得所有科室
local function findExaminaDept()
    local org_id = request:getNumParam("org_id", true, true) --
    local org_type = request:getNumParam("org_type", true, true) --
    local  resultInfo = service.findExaminaDept(org_id,org_type);
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo }))
    return;
end

--获得所有科室及其以下的所有审批人员信息
local function findExaminaOfficeAndPerson()
    local org_id = request:getNumParam("org_id", true, true) --
    local org_type = request:getNumParam("org_type", true, true) --
    local  resultInfo = service.findExaminaOfficeAndPerson(org_id,org_type);
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo }))
    return;
end




--增加一个申请！！！！！！！！！！！！！！
local function addExaminaRequest()
    local person_id = request:getNumParam("person_id", true, true) --申请人
    local identity_id = request:getNumParam("identity_id", true, true) --
    local status = request:getNumParam("status",true,true)
    local office_id = request:getNumParam("office_id",true,true)
    local org_id = request:getNumParam("org_id", true, true) --
    local attachment = request:getStrParam("attachment", false, false) --
    local org_type = request:getNumParam("org_type", true, true) --
    local explain_info = request:getStrParam("explain_info",false,false)
    local project_name = request:getStrParam("project_name",true,true)

    local aService = require "space.services.PersonAndOrgBaseInfoService"--获取学校类型的参数
    local temp = {org_id}
    local schoolResults = aService:getSchoolInfoBySchoolids( temp)
    local stage_type = schoolResults[1]["school_type"]

    local detail = request:getStrParam("detail",true,true)--获取detail
    detail = cjson.decode(detail)

    if type(detail[1])~='table' then
        ngx.say("detail格式有误")
        return;
    end
    local money = 0
    for i = 1,#detail do
        if not detail[i]["total_money"] then
            ngx.say("detail有误:没有total_money")
            return;
        end
        money = money +detail[i]["total_money"]
    end
    local result, id = service.addExaminaRequest({
        person_id = person_id,
        identity_id=identity_id,
        org_id = org_id,
        org_type = org_type,
        office_id = office_id,
        status = status,
        explain_info=explain_info,
        project_name=project_name,
        money = money,
        attachment = attachment,
        stage_type=stage_type,
    },detail);
    if not result then
        ngx.say(cjson.encode({ success = result }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end


--修改申请单
local function updateExaminaRequest()
    local person_id = request:getNumParam("person_id", true, true) --申请人
    local identity_id = request:getNumParam("identity_id", true, true) --
    local index = request:getNumParam("index",true,true)
    local status
    if index ==0 then
        status = 0
    elseif index == 1 then
        status = 1
    else
        ngx.say("index is wrong")
    end
    local office_id = request:getNumParam("office_id",true,true)
    local org_id = request:getNumParam("org_id", true, true) --
    local attachment = request:getStrParam("attachment", false, false) --
    local org_type = request:getNumParam("org_type", true, true) --
    local id = request:getNumParam("id",true,true)--
    local explain_info = request:getStrParam("explain_info",false,false)
    local project_name = request:getStrParam("project_name",true,true)

    local aService = require "space.services.PersonAndOrgBaseInfoService"
    local temp = {org_id}
    local schoolResults = aService:getSchoolInfoBySchoolids( temp)
    local stage_type = schoolResults[1]["school_type"]

    local detail = request:getStrParam("detail",true,true)
    detail = cjson.decode(detail)
    local money = 0
    for i = 1,#detail do
        money = money +detail[i]["total_money"]
    end
    local result, id = service.update({
        id=id,
        person_id = person_id,
        identity_id=identity_id,
        org_id = org_id,
        org_type = org_type,
        office_id = office_id,
        status = status,
        stage_type=stage_type,
        explain_info=explain_info,
        project_name=project_name,
        money = money,
        attachment = attachment,
    },detail);
    if not result then
        ngx.say(cjson.encode({ success = result }))
        return;
    end
    ngx.say(cjson.encode({ success = result, id = id }))
    return;
end

--除了科室以外的审批中，已通过，未通过
local function findExaminaInfoExOfficeByStatus()
    local status = request:getNumParam('status',true,true)
    local page_size = request:getNumParam('page_size',true,true)
    local page_num = request:getNumParam('page_num',true,true)
    local level = request:getNumParam('level',true,true)
    local org_id
    local org_type
    local search_str = request:getStrParam('search_str',false,false)
    if level ==1 then
        org_id = request:getNumParam('org_id',true,true)
        org_type =request:getNumParam('org_type',true,true)
    else
        org_id = 0
        org_type = 0
    end
    local result,total_page,total_row = service.findExaminaInfoExOfficeByStatus(status,org_id,org_type,page_size,page_num,search_str)
    if not result then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = result,total_page=total_page,page_size=page_size,page_num=page_num,total_row=total_row }))
    return;
end

--科室审批中，已通过，未通过
local function findExaminaInfoOfficeByStatus()
    local status = request:getNumParam('status',true,true)
    local office_id = request:getNumParam('office_id',true,true)
    local page_num = request:getNumParam('page_num',true,true)
    local page_size = request:getNumParam("page_size",true,true)
    local result,total_page,total_row = service.findExaminaInfoOfficeByStatus(status,office_id,page_size,page_num)

    if not result then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = result,total_page =total_page,page_num=page_num,page_size=page_size,total_row=total_row }))
    return;
end

--处理申请
local function dealExaminaRequest()
    local info_id = request:getNumParam("info_id",true,true)
    local e_p_id = request:getNumParam("e_p_id",true,true)
    local status = request:getNumParam("status",true,true) --1通过，2驳回
    local remarks = ""
    if status ==2   then
        remarks = request:getStrParam('remarks',true,true)
    end

    local level = request:getNumParam("level",true,true)
    local result = service.dealExaminaRequest({
        info_id=info_id ,
        e_p_id = e_p_id,
        status = status,
        level = level,
        remarks = remarks,
    });
    if not result then
        ngx.say(cjson.encode({success = false}))
        return;
    end
    ngx.say(cjson.encode({success = result}))
end
--local function subUri(uri)
--    local _,po2 = string.find(uri,'menu/')  --po2 'menu/'末位置
--    local index = string.find(uri,'.do')    --index '.do'前位置
--    local resoure =  string.sub(uri,po2,index)
--    return resoure
--end
--获得审批人员的信息
local function getPersonInfo()
    local person_id = request:getNumParam("person_id",true,true)
    local identity_id = request:getNumParam("identity_id",true,true)
    local org_id = request:getNumParam("org_id",true,true)
    local org_type = request:getNumParam("org_type",true,true)
    local resultInfo =  service.getPersonInfo(person_id,identity_id,org_id,org_type)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo }))
    return;

end

--待审批
local function findHavenotExaminaInfo()
    local org_type
    local org_id
    local office_id
    local level = request:getNumParam("level",true,true)
    local page_size = request:getNumParam("page_size",true,true)
    local page_num = request:getNumParam("page_num",true,true)

    if level==1 then
        org_type = request:getNumParam("org_type",true,true)
        org_id= request:getNumParam("org_id",true,true)
    end
    if level ==2 then
        office_id = request:getNumParam("office_id",true,true)
    end
    local resultInfo,total_page,total_row = service.findHavenotExaminaInfo(level,page_size,page_num,org_type,org_id,office_id)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo,total_page=total_page,page_size=page_size,page_num=page_num,total_row=total_row }))
    return;
end

--获取详细信息
local function findRequestInfo()
    local id = request:getNumParam("id",true,true)
    local person_id = request:getNumParam("person_id",true,true)--必须以登陆人的身份调用,防君子不防小人
    local identity_id = request:getNumParam("identity_id",true,true)

    local result = service.findRequestInfo(id)
    for i = 1, #result do
        local pic_res = result[i]['attachment'];
        local pic_table = Split(pic_res, ",")
        local pic_list = {}
        for j = 1, #pic_table do
            table.insert(pic_list, { res_id = pic_table[j], is_cloud = 0 })
        end
        ssdb_dao.reloadResourceM3U8Info(pic_list)
        if not pic_list[i]['file_id'] or pic_list[i]['file_id']=="" then
            pic_list[i] = nil
        end
        result[i].attachment_list = pic_list
    end
    if not result then
        ngx.say(cjson.encode({success = false}))
        return;
    end
    ngx.say(cjson.encode({success = result}))
end

--申请人自发取消申请，防止他写错
local function cancleRequest()
    local org_id = request:getNumParam("org_id",true,true)
    local org_type = request:getNumParam("org_type",true,true)
    local info_id = request:getNumParam("info_id",true,true)
    local result = service.cancleRequest(org_id,org_type,info_id)
    if not result then
        ngx.say(cjson.encode({success = false}))
        return;
    end
    ngx.say(cjson.encode({success = result}))
end

--教师根据状态筛选
local function teacherFindInfoByStatus()
    local person_id = request:getNumParam("person_id",true,true)
    local status = request:getNumParam("status",true,true)
    local org_id = request:getNumParam("org_id",true,true)
    local org_type = request:getNumParam("org_type",true,true)
    local page_num = request:getNumParam("page_num",true,true)
    local page_size = request:getNumParam("page_size",true,true)
    local search_str = request:getStrParam("search_str",false,false)
    local resultInfo,total_page,total_row = service.teacherFindInfoByStatus(person_id,status,org_id,org_type,page_num,page_size,search_str)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo,total_page=total_page,page_num=page_num,page_size=page_size,total_row=total_row }))
    return;
end

--按照学期查总金额
local function caculateMoneyBydate()
    local index = request:getNumParam("index",true,true)
    local whichLevel = request:getNumParam("whichLevel",true,true)
    local org_id
    local org_type
    local office_id
    if whichLevel==1 or whichLevel ==3 then
        org_id = request:getNumParam("org_id",true,true)
        org_type = request:getNumParam("org_type",true,true)
    elseif whichLevel == 2 then
        office_id = request:getNumParam("office_id",true,true)
    end

    local resultInfo
    local start_time
    local end_time
    if index == 3 then
        start_time  = request:getStrParam("start_time",true,true)
        end_time = request:getStrParam("end_time",true,true)
    end

    resultInfo = service.caculateMoneyBydate(index,start_time,end_time,whichLevel,org_id,org_type,office_id)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, totalMoney = resultInfo }))
    return;

end
--后台专用通过id直接删申请单，没做成批量。
local function deleteInfoById()
    local id = request:getNumParam('id',true,true)
    local resultInfo = service.deleteInfoById(id)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, resultInfo = resultInfo }))
    return;
end

--教师删除未提交的申请
local function deleteNoComitInfoById()
    local id = request:getNumParam('id',true,true)
    local org_id = request:getNumParam("org_id",true,true)
    local org_type = request:getNumParam("org_type",true,true)
    local person_id = request:getNumParam('person_id',true,true)
    local identity_id = request:getNumParam('identity_id',true,true)
    local resultInfo = service.deleteNoComitInfoById(id,org_id,org_type,person_id,identity_id)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, result_info = resultInfo }))
    return;
end

--通过项目编码查找申请单
local function findExaminaInfoByCode()
    local org_id = request:getNumParam("org_id",true,true)
    local org_type = request:getNumParam("org_type",true,true)
    local page_num = request:getNumParam("page_num",true,true)
    local page_size = request:getNumParam("page_size",true,true)
    local search_str = request:getStrParam("search_str",false,false)
    local status = request:getNumParam("status",true,true)
    local resultInfo,total_page,total_row = service.findExaminaInfoByCode(org_id,org_type,page_num,page_size,search_str,status)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo,total_page=total_page,page_num=page_num,page_size=page_size,total_row=total_row }))
    return;
end

--将保存的直接提交
local function saveToUpload()
    local org_id = request:getNumParam("org_id",true,true)
    local org_type = request:getNumParam("org_type",true,true)
    local id = request:getNumParam("id",true,true)
    local person_id = request:getNumParam("person_id",true,true)
    local identity_id = request:getNumParam("identity_id",true,true)
    local resultInfo = service.saveToUpload(org_id,org_type,id,person_id,identity_id)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true }))
    return;
end

--局长根据学校类型，时间，获取money
local function findMoneyBySchoolType()
    --0:全部 1:小学，2:初中，3:高中，4:完全中学，5:九年一贯制，6:十二年一贯制，7:大学，8:职业，9:幼儿 10：小幼一体  11：小幼初一体
    local stage_type = request:getNumParam("stage_type",true,true)
    local time_index = request:getNumParam("time_index",true,true)
    local status = request:getNumParam("status",true,true)
    local start_time = "0"
    local end_time ="0"
    if time_index== 1 then
        start_time = request:getStrParam("start_time",true,true)
        end_time = request:getStrParam("end_time",true,true)
    end
    local office_id =request:getNumParam("office_id",true,true)

    local search_str = request:getStrParam("search_str",false,false)
    local page_size = request:getNumParam("page_size",true,true)
    local page_num = request:getNumParam("page_num",true,true)
    local resultInfo,total_page,total_row = service.findMoneyBySchoolType(stage_type,time_index,start_time,end_time,search_str,page_size,page_num,status,office_id)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo,total_page=total_page,page_num=page_num,page_size=page_size,total_row=total_row }))
    return;

end

--科室统计
local function findMoneyByOffice()
    local time_index = request:getNumParam("time_index",true,true)
    local status = request:getNumParam("status",true,true)
    local office_id= request:getNumParam("office_id",true,true)
    local start_time = "0"
    local end_time ="0"
    if time_index== 1 then
        start_time = request:getStrParam("start_time",true,true)
        end_time = request:getStrParam("end_time",true,true)
    end
    local page_size = request:getNumParam("page_size",true,true)
    local page_num = request:getNumParam("page_num",true,true)
    local resultInfo,total_page,total_row = service.findMoneyByOffice(time_index,start_time,end_time,page_size,page_num,status,office_id)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo,total_page=total_page,page_num=page_num,page_size=page_size,total_row=total_row }))
    return;

end

--更具学校查看申请单
local function findInfoByOrgId()
    local org_id = request:getNumParam("org_id",true,true)
    local time_index = request:getNumParam("time_index",true,true)
    local org_type = request:getNumParam("org_type",true,true)
    local page_num = request:getNumParam("page_num",true,true)
    local page_size = request:getNumParam("page_size",true,true)
    local status = request:getNumParam("status",true,true)
    local office_id = request:getNumParam("office_id",true,true)
    local start_time = "0"
    local end_time ="0"
    if time_index== 1 then
        start_time = request:getStrParam("start_time",true,true)
        end_time = request:getStrParam("end_time",true,true)
    end
    log:debug(status)
    log:debug("office:"..office_id)
    local resultInfo,total_page,total_row = service.findInfoByOrgId(org_id,org_type,page_size,page_num,status,start_time,end_time,office_id)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo,total_page=total_page,page_num=page_num,page_size=page_size,total_row=total_row }))
    return;
end

--查看当前级别和当前申请单所代表的学校的金额
local function findTotalAndSchool()
    local org_id = request:getNumParam("org_id",true,true)
    local org_type = request:getNumParam("org_type",true,true)
    local index = request:getNumParam("index",true,true)   --1.校长级，2科室，3，局长
--    local info_id = request:getNumParam("info_id",true,true)
    local office_id = 0
    if index ==2 then
        office_id = request:getNumParam("office_id",true,true)
    end
    local time_index = request:getNumParam("time_index",true,true)
    local start_time = "0"
    local end_time ="0"
    if time_index== 3 then
        start_time = request:getStrParam("start_time",true,true)
        end_time = request:getStrParam("end_time",true,true)
    end
    local resultInfo = service.findTotalAndSchool(org_id,org_type,index,start_time,end_time,office_id,time_index)
    if not resultInfo then
        ngx.say(cjson.encode({ success = false }))
        return;
    end
    ngx.say(cjson.encode({ success = true, list = resultInfo }))
    return;
end

local urls = {
    GET = {
        permission_context..'/demo1', demo1,
        permission_context..'/findDept$',findExaminaDept,
        permission_context..'/findDeptPerson',findExaminaDeptPerson,
        permission_context..'/findExDeptPerson',findExaminaExDeptPerson,
        permission_context..'/findOfficeAndPerson',findExaminaOfficeAndPerson,
        permission_context..'/findExaminaingExOffice',findExaminaInfoExOfficeByStatus,
        permission_context..'/findExaminaingOffice',findExaminaInfoOfficeByStatus,
        permission_context..'/getPersonInfo',getPersonInfo,
        permission_context..'/findHavenotExamina',findHavenotExaminaInfo,
        permission_context ..'/findRequestInfo',findRequestInfo,
        permission_context ..'/teacherFindInfoByStatus',teacherFindInfoByStatus,
        permission_context ..'/caculateMoneyBydate',caculateMoneyBydate,
        permission_context ..'/findExaminaInfoByCode',findExaminaInfoByCode,
        permission_context ..'/findMoneyBySchoolType',findMoneyBySchoolType,
        permission_context ..'/findMoneyByOffice',findMoneyByOffice,
        permission_context ..'/findInfoByOrgId',findInfoByOrgId,
        permission_context ..'/findTotalAndSchool',findTotalAndSchool

    },
    POST = {
--        permission_context .. '/update', updateApplication,
--        permission_context .. '/delete', deleteApplication,
        permission_context ..'/addPerson$', addExaminaPerson,
        permission_context ..'/addPersons', addExaminaPersons,
        permission_context ..'/removePerson',removeExaminaPerson,
        permission_context ..'/addOffice', addExaminaOffice,
        permission_context ..'/removeOffice',removeExaminaOffice,
        permission_context ..'/addPerson', addExaminaPerson,
        permission_context ..'/addRequest', addExaminaRequest,
        permission_context ..'/dealRequset', dealExaminaRequest,
        permission_context ..'/cancleRequest',cancleRequest,
        permission_context ..'/updateExaminaRequest',updateExaminaRequest,
        permission_context ..'/deleteInfoById',deleteInfoById,
        permission_context ..'/deleteNoComitInfoById',deleteNoComitInfoById,
        permission_context ..'/saveToUpload',saveToUpload,

    }
}
local app = web.application(urls, nil)
app:start()
