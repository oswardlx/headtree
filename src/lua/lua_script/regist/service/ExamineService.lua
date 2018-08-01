--
-- Created by IntelliJ IDEA.
-- User: 91946
-- Date: 2017/11/16
-- Time: 11:32
-- To change this template use File | Settings | File Templates.
--
local baseService = require("social.service.CommonBaseService")
local dao = require("space.examine.dao.ExamineMysqlDao")
local TableUtil = require("social.common.table")
local _util  = require "new_base.util"
local cjson = require "cjson"
local log = require("social.common.log4j"):new()
local _PersonInfo = require("space.services.PersonAndOrgBaseInfoService")
local _M = {}

--虽然主要业务的实现都在service和dao。但是确实有点懒得全都写注释，ctl里有注释。
--其实里面有写地方是可以优化的。但是当时写的时候是一个一个接口写的。没想到后来有些地方是可以重用的，现在目前测试已经可以了。
--目前没有对代码简洁性的要求。我就先这样吧。下次注意。
function _M.addExaminaPerson(param)

    baseService:checkParamIsNull({
        person_id =param.person_id,
        identity_id = param.identity_id,
        level = param.level,
        person_name = param.person_name,
        org_id = param.org_id,
        org_type = param.org_type,
        dept_id = param.dept_id,
        office_id = param.office_id
    });
    local result, id
    local func = function()
        local result = dao.findExaminePersonById(param.person_id,param.identity_id)
        log:debug(result)
        result, id = dao.addExaminaPerson(param);
    end
    local status = dao.txFunction(func)
    return status,id

end

--限制重复添加同一个人
function _M.getTFsamePerson()

end

function _M.addExaminaPersons(personList)
    local result = {}
    local func = function()
        for i = 1,#personList do

            baseService:checkParamIsNull({
                person_id =personList[i].person_id,
                identity_id = personList[i].identity_id,
                level = personList[i].level,
                person_name = personList[i].person_name,
                org_id = personList[i].org_id,
                org_type = personList[i].org_type,
                dept_id = personList[i].dept_id,
                office_id = personList[i].office_id
            });
            dao.findExaminePersonById(personList[i].person_id,personList[i].identity_id)
            result[i]  = dao.addExaminaPerson(personList[i]);
        end
    end
    local status = dao.txFunction(func)
    return status

end

function _M.addExaminaRequest(param,detail)
    log:debug(11111111111111)
    local _id;
    local func = function()
        log:debug(222222222)
        local day_sequence = dao.findDaySequence()
        log:debug(day_sequence)
        local code = string.gsub(os.date("%Y-%m-%d"),"-","")..day_sequence
        baseService:checkParamIsNull({
            office_id = param.office_id,
            person_id =param.person_id,
            identity_id = param.identity_id,
            status = param.status,
            project_name = param.project_name,
            org_id = param.org_id,
            org_type = param.org_type,
            stage_type=param.stage_type,
        });
        param.day_sequence = tonumber(day_sequence)
        param.project_code = code
        param.order_code = code
        local result, id = dao.addExaminaRequest(param);
        log:debug(result)
        _id = id
        for i = 1 ,#detail do
            baseService:checkParamIsNull({
                name = detail[i]['name'],
                attachment = detail[i]['attachment'],
                unit = detail[i]['unit'],
                num = detail[i]['num'],
                total_money = detail[i]['total_money'],
                info_id = id,
                price_money = detail[i]['price_money']
            });
            detail[i]['info_id'] = id
            local resulti,idi = dao.addExaminaRequestDetail(detail[i])
        end
    end
    local status = dao.txFunction(func)
    return status, _id
end


function _M.removeExaminaPerson(id)
    baseService:checkParamIsNull({id=id});
    local result = dao.removeExaminaPerson(id);
    return result
end

--function _M.findExaminaOrgPerson(org_id,org_type)
--    baseService:checkParamIsNull({org_id=org_id,org_type=org_type});
--    local resultInfo = dao.findExaminaOrgPerson(org_id,org_type);
--    return resultInfo
--end

function _M.findExaminaDeptPerson(office_id)
    baseService:checkParamIsNull({office_id=office_id});
    local resultInfo = dao.findExaminaDeptPerson(office_id);
    for i =1,#resultInfo do
        local person_id = resultInfo[i]['person_id']
        local person_res = _util:getPersonInfoByPersonId(person_id)
        if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
            resultInfo[i]["xb_name"]="男"
        else
            resultInfo[i]["xb_name"] = tostring(person_res[1]["xb_name"])
        end
--        resultInfo[i]["xb_name"] = tostring(person_res[1]["xb_name"])
        resultInfo[i]["org_name"] = tostring(person_res[1]["org_name"])
        resultInfo[i]["workers_no"] = tostring(person_res[1]["workers_no"])
    end
    return resultInfo
end

function _M.findExaminaExDeptPerson(level,org_id,org_type)
    baseService:checkParamIsNull({office_id=level,org_id,org_type});
    local resultInfo = dao.findExaminaExDeptPerson(level,org_id,org_type);
    for i =1,#resultInfo do
        local person_id = resultInfo[i]['person_id']
        local person_res = _util:getPersonInfoByPersonId(person_id)
        if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
            resultInfo[i]["xb_name"]="男"
        else
            resultInfo[i]["xb_name"] = tostring(person_res[1]["xb_name"])
        end
        resultInfo[i]["org_name"] = tostring(person_res[1]["org_name"])
        resultInfo[i]["workers_no"] = tostring(person_res[1]["workers_no"])----他的表里事
    end
    return resultInfo
end

function _M.addExaminaOffice(param)
    baseService:checkParamIsNull({
        office_name = param.office_name,
        org_id = param.org_id,
        org_type = param.org_type,
        dept_id = param.dept_id

    });
    local result, id = dao.addExaminaOffice(param);
    return result, id
end

function _M.removeExaminaOffice(office_id)
    baseService:checkParamIsNull({office_id=office_id});
    local func = function()
        dao.removeExaminaOffice(office_id);
        dao.removeExaminaPersonByOfficeId(office_id);
    end
    local status = dao.txFunction(func)
    return status
end

function _M.findExaminaDept(org_id,org_type)
    local resultInfo = dao.findExaminaDept(org_id,org_type);
    return resultInfo
end

function _M.findExaminaOfficeAndPerson(org_id,org_type)
    local resultInfo1 = dao.findExaminaDept(org_id,org_type);
    log:debug(resultInfo1)
    for i = 1,#resultInfo1 do
        local office_id = resultInfo1[i]['id']
        local resultInfo2 = dao.findExaminaOfficePerson(office_id);
        for j =1,#resultInfo2 do
            local person_id = resultInfo2[j]['person_id']
            local person_res = _util:getPersonInfoByPersonId(person_id)
            if TableUtil:length(person_res)>0 then
                if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
                    resultInfo2[j]["xb_name"]="男"
                else
                    resultInfo2[j]["xb_name"] = tostring(person_res[1]["xb_name"])
                end
                resultInfo2[j]["xb_name"] = tostring(person_res[1]["xb_name"])
                resultInfo2[j]["org_name"] = tostring(person_res[1]["org_name"])
                resultInfo2[j]["workers_no"] = tostring(person_res[1]["workers_no"])
            end
        end
        resultInfo1[i]['person_list'] = resultInfo2
    end
    return resultInfo1
end
function _M.findExaminaInfoExOfficeByStatus(status,org_id,org_type,page_size,page_num,search_str)
    local resultInfo,total_page,total_row = dao.findExaminaInfoExOfficeByStatus(status,org_id,org_type,page_size,page_num,search_str)
    for j =1,#resultInfo do
        local person_id = resultInfo[j]['person_id']
        local person_res = _util:getPersonInfoByPersonId(person_id)
        if TableUtil:length(person_res)>0 then
            if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
                resultInfo[j]["xb_name"]="男"
            else
                resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            end
--            resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            resultInfo[j]["org_name"] = tostring(person_res[1]["org_name"])
            resultInfo[j]["workers_no"] = tostring(person_res[1]["workers_no"])
            resultInfo[j]["person_name"]  = tostring(person_res[1]["person_name"])
        end
        local resultInfo2 = dao.findOfficeInfoByOfficeId(resultInfo[j]["office_id"])
        if TableUtil:length(resultInfo2)>0 then
            resultInfo[j]["office_name"]  = tostring(resultInfo2[1]["office_name"])
        else
            resultInfo[j]["office_name"]  = "无"
        end
        resultInfo[j]["details"] = dao.findInfoDetail(resultInfo[j]["id"])
    end

    return resultInfo,total_page,total_row;
end

function _M.findExaminaInfoOfficeByStatus(status,office_id,page_size,page_num)
    log:debug("findExaminaInfoOfficeByStatus")
    local resultInfo,totalpage,total_row = dao.findExaminaInfoOfficeByStatus(status,office_id,page_size,page_num)

    for j =1,#resultInfo do
        local person_id = resultInfo[j]['person_id']
        local person_res = _util:getPersonInfoByPersonId(person_id)
        if TableUtil:length(person_res)>0 then
            if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
                resultInfo[j]["xb_name"]="男"
            else
                resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            end
--            resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            resultInfo[j]["org_name"] = tostring(person_res[1]["org_name"])
            resultInfo[j]["workers_no"] = tostring(person_res[1]["workers_no"])
            resultInfo[j]["person_name"]  = tostring(person_res[1]["person_name"])
        end
        local resultInfo2 = dao.findOfficeInfoByOfficeId(resultInfo[j]["office_id"])
        if TableUtil:length(resultInfo2)>0 then
            resultInfo[j]["office_name"]  = tostring(resultInfo2[1]["office_name"])
        else
            resultInfo[j]["office_name"]  = "无"
        end
        resultInfo[j]["details"] = dao.findInfoDetail(resultInfo[j]["id"])
    end
    return resultInfo,totalpage,total_row;
end

function _M.teacherFindInfoByStatus(person_id,status,org_id,org_type,page_num,page_size,search_str)
    local resultInfo,totalpage,total_row = dao.teacherFindInfoByStatus(person_id,status,org_id,org_type,page_num,page_size,search_str)
    for j =1,#resultInfo do
        local person_id = resultInfo[j]['person_id']
        local person_res = _util:getPersonInfoByPersonId(person_id)
        if TableUtil:length(person_res)>0 then
            if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
                resultInfo[j]["xb_name"]="男"
            else
                resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            end
--            resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            resultInfo[j]["org_name"] = tostring(person_res[1]["org_name"])
            resultInfo[j]["workers_no"] = tostring(person_res[1]["workers_no"])
            resultInfo[j]["person_name"]  = tostring(person_res[1]["person_name"])
        end
        local resultInfo2 = dao.findOfficeInfoByOfficeId(resultInfo[j]["office_id"])
        if TableUtil:length(resultInfo2)>0 then
            resultInfo[j]["office_name"]  = tostring(resultInfo2[1]["office_name"])
        else
            resultInfo[j]["office_name"]  = "无"
        end
        resultInfo[j]["details"] = dao.findInfoDetail(resultInfo[j]["id"])
    end
    return resultInfo,totalpage,total_row;
end

function _M.dealExaminaRequest(param)
--    local result = dao.dealExaminaRequest(param)
--    local status = param.status
--    local level = param.level
--    local result2
--    if status ==2 then
--        result2 = dao.disagree(param.info_id)
--    elseif level ==3 then
--        result2 = dao.complete(param.info_id)
--    end
--    return result
--    local func = function()
--        dao.removeExaminaOffice(office_id);
--        dao.removeExaminaPersonByOfficeId(office_id);
--    end
--    local status = dao.txFunction(func)
--    return status
      local status = param.status
      local level = param.level
      local index = _M.getTFdealRequest(param.info_id,level)
      if TableUtil:length(index)>0 then
          return false
      end

      local func
      if status ==2 then
          func = function()
              dao.dealExaminaRequest(param)
              dao.disagree(param.info_id)
          end
      elseif level ==3 then
          func = function()
              dao.dealExaminaRequest(param)
              dao.complete(param.info_id)
          end
      else
          func = function()
            dao.dealExaminaRequest(param)
          end
      end

      local status = dao.txFunction(func)
      return status
end


--判断是否已存在
function _M.getTFdealRequest(info_id,level)
    local result = dao.getTFdealRequest(info_id,level)
    return result
end



function _M.getPersonInfo(person_id,identity_id,org_id,org_type)
    local result = dao.getPersonInfo(person_id,identity_id,org_id,org_type)
    return result
end

function _M.findHavenotExaminaInfo(level,page_size,page_num,org_type,org_id,office_id)
    local resultInfo
    local total_page=0
    local total_row
    if 1==level then
        resultInfo,total_page,total_row= dao.findHavenotExaminaInfo1(level,page_size,page_num,org_id,org_type)
    elseif 2==level then
        resultInfo,total_page,total_row = dao.findHavenotExaminaInfo2(level,page_size,page_num,office_id)
    elseif 3 ==level then
        resultInfo,total_page,total_row = dao.findHavenotExaminaInfo3(level,page_size,page_num)
    end
    for j =1,#resultInfo do
        local person_id = resultInfo[j]['person_id']
        local person_res = _util:getPersonInfoByPersonId(person_id)
        if TableUtil:length(person_res)>0 then
            if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
                resultInfo[j]["xb_name"]="男"
            else
                resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            end
--            resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            resultInfo[j]["org_name"] = tostring(person_res[1]["org_name"])
            resultInfo[j]["workers_no"] = tostring(person_res[1]["workers_no"])
            resultInfo[j]["person_name"]  = tostring(person_res[1]["person_name"])
        end
        local resultInfo2 = dao.findOfficeInfoByOfficeId(resultInfo[j]["office_id"])
        if TableUtil:length(resultInfo2)>0 then
            resultInfo[j]["office_name"]  = tostring(resultInfo2[1]["office_name"])
        else
            resultInfo[j]["office_name"]  = "无"
        end
        resultInfo[j]["details"] = dao.findInfoDetail(resultInfo[j]["id"])
    end
    return resultInfo,total_page,total_row
end

function _M.findRequestInfo(id)

    local resultInfo = dao.findRequestInfo(id)
    for j =1,#resultInfo do
        local status_info = dao.findStatusInfo(id)
        local remarks = ""
        for i =1 ,#status_info do
            local e_p_id = status_info[i]["e_p_id"]
            if status_info[i]['remarks'] then
                remarks = status_info[i]['remarks']
            end
            local e_p_res= {}
            if e_p_id then
              e_p_res = _util:getPersonInfoByPersonId(e_p_id)
            end
            if TableUtil:length(e_p_res)>0 then
                if tostring(e_p_res[1]["xb_name"])=="userdata: NULL" then
                    status_info[i]["xb_name"]="男"
                else
                    status_info[i]["xb_name"] = tostring(e_p_res[1]["xb_name"])
                end
--                status_info[i]["xb_name"] = tostring(e_p_res[1]["xb_name"])
                status_info[i]["org_name"] = tostring(e_p_res[1]["org_name"])
                status_info[i]["workers_no"] = tostring(e_p_res[1]["workers_no"])
                status_info[i]["person_name"]  = tostring(e_p_res[1]["person_name"])
            end
        end

        local person_id = resultInfo[j]['person_id']
        local identity_id = resultInfo[j]['identity_id']
        local org_id = resultInfo[j]['org_id']
        local person_res = _util:getPersonInfoByPersonId(person_id)
        local school_name =_PersonInfo:getSchoolNameAndClassNameByPersonId(person_id,identity_id)

        if TableUtil:length(person_res)>0 then
            if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
                resultInfo[j]["xb_name"]="男"
            else
                resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            end
--            resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])


            resultInfo[j]["workers_no"] = tostring(person_res[1]["workers_no"])
            resultInfo[j]["person_name"]  = tostring(person_res[1]["person_name"])
        end
        local resultInfo2 = dao.findOfficeInfoByOfficeId(resultInfo[j]["office_id"])
        if TableUtil:length(resultInfo2)>0 then
            resultInfo[j]["office_name"]  = tostring(resultInfo2[1]["office_name"])
        else
            resultInfo[j]["office_name"]  = "无"
        end
        resultInfo[j]["org_name"] = _M.findSchoolNmae(org_id)

        resultInfo[j]["details"] = dao.findInfoDetail(resultInfo[j]["id"])
        resultInfo[j]["status_info"] = status_info
        resultInfo[j]["remarks"] = remarks
    end
    return resultInfo
end

function _M.findSchoolNmae(org_id)
    local data = ngx.location.capture("/dsideal_yy/management/sys/org/getEduUnitByOrgId?org_id="..org_id)
    local _data;
    if data.status ==200 then
        _data = cjson.decode(data.body)
        log:debug(_data)
        log:debug(_data['ORG_NAME'])
        local org_name = _data['ORG_NAME']
        if org_name then
            return org_name
        else
            return "获取学校名字失败"
        end
    end
end

function _M.cancleRequest(org_id,org_type,info_id)
    local result = dao.cancleRequest(org_id,org_type,info_id)
    return result
end

local function formatStrtodate(timeString)
    local Y = string.sub(timeString , 1, 4)
    local M = string.sub(timeString , 6, 7)
    local D = string.sub(timeString , 9, 10)
    return os.time({year=Y, month=M, day=D, hour=0,min=0,sec=0})
end

local function table_sort(date_table,method)
    local _table = date_table
    local function sort_asc(a, b)
        return formatStrtodate(a)>formatStrtodate(b)
    end
    local function sort_desc(a, b)
        return formatStrtodate(a)<formatStrtodate(b)
    end
    table.sort(_table,method and sort_asc or sort_desc)
    return _table;
end

local function table_max(date_table)
    table_sort(date_table,false)
    return date_table;

end

local function table_min(date_table)
    table_sort(date_table,true)
    return date_table;
end

function _M.caculateMoneyBydate(index,start_time,end_time,whichLevel,org_id,org_type,office_id)
    local data = ngx.location.capture("/dsideal_yy/subject/getListSemester")
    local _data;
    if data.status ==200 then
        _data = cjson.decode(data.body)
        local xqlist = _data.xqlist
        local inTermstart
        local inTermend
        local inYearstart
        local inYearend
        local inWhatever
        local XN
        local current_year = tonumber(os.date("%Y"))
        local time_table = {}
        if xqlist and TableUtil:length(xqlist) > 0 then
            for i =1 ,#xqlist do
                if xqlist[i]["SFDQXQ"] ==1 then
                    inTermstart = xqlist[i]["KSRQ"]
                    inTermend = xqlist[i]["JSRQ"]
                    XN = xqlist[i]["XN"]
                    if current_year == XN then
                        table.insert(time_table,formatStrtodate(xqlist[i]["KSRQ"]))
                        table.insert(time_table,formatStrtodate(xqlist[i]["JSRQ"]))
                        if not xqlist[i+1] then
                            table.insert(time_table,formatStrtodate(XN.."-12-31"))
                        else
                            table.insert(time_table,formatStrtodate(xqlist[i+1]["KSRQ"]))
                            table.insert(time_table,formatStrtodate(xqlist[i+1]["JSRQ"]))
                        end
                    end

                    inYearstart = os.date("%Y-%m-%d",table_max(time_table)[1])
                    inYearend = os.date("%Y-%m-%d",table_min(time_table)[1])
                end
            end
            local born_time = 0
            local dead_time = 0
            if index== 1 then
                born_time = inTermstart.." 00:00:00"
                dead_time = inTermend.." 23:59:59"
            elseif index ==2 then
                born_time = inYearstart.." 00:00:00"
                dead_time = inYearend.." 23:59:59"
            elseif index ==3 then
                born_time = start_time.." 00:00:00"
                dead_time = end_time.." 23:59:59"
            end                    --前端急着要接口没时间写备注了
            local result
            log:debug(born_time)
            log:debug(dead_time)
            if whichLevel==1 or whichLevel ==3 then
                result = dao.getInfoListBydateAndOrg(born_time,dead_time,org_id,org_type)
            elseif whichLevel == 2 then
                result = dao.getInfoListBydateAndLevel(born_time,dead_time,office_id)
            end

            local totalmoney=0
            for k = 1,#result do
                totalmoney = totalmoney +result[k]["money"]
            end
            return totalmoney
        end
    end
end

function _M.update(param,detail)
    log:debug("update")
    baseService:checkParamIsNull({
        id=param.id,
        office_id = param.office_id,
        person_id =param.person_id,
        identity_id = param.identity_id,
        project_name = param.project_name,
        stage_type=param.stage_type,
        org_id = param.org_id,
        org_type = param.org_type
    });
    local _id;
    local func = function()
        local result, id = dao.updateInfo(param);
        _id = id
        local result1 = dao.deleteDetailByInfoId(_id)
        for i = 1 ,#detail do
            detail[i].info_id = _id
            local resulti,idi = dao.addExaminaRequestDetail(detail[i])
        end
    end
    local status = dao.txFunction(func)
    return status, _id
end

function _M.findExaminaInfoByCode(org_id,org_type,page_num,page_size,search_str,status)
    local resultInfo,totalpage,total_row = dao.findExaminaInfoByCode(org_id,org_type,page_num,page_size,search_str,status)
    for j =1,#resultInfo do
        local person_id = resultInfo[j]['person_id']
        log:debug(person_id)
        local person_res = _util:getPersonInfoByPersonId(person_id)
        if TableUtil:length(person_res)>0 then
            if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
                resultInfo[j]["xb_name"]="男"
            else
                resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            end
--            resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            resultInfo[j]["org_name"] = tostring(person_res[1]["org_name"])
            resultInfo[j]["workers_no"] = tostring(person_res[1]["workers_no"])
            resultInfo[j]["person_name"]  = tostring(person_res[1]["person_name"])
        end

        local resultInfo2 = dao.findOfficeInfoByOfficeId(resultInfo[j]["office_id"])
        if TableUtil:length(resultInfo2)>0 then
            resultInfo[j]["office_name"]  = tostring(resultInfo2[1]["office_name"])
        else
            resultInfo[j]["office_name"]  = "无"
        end
        resultInfo[j]["details"] = dao.findInfoDetail(resultInfo[j]["id"])
    end
    return resultInfo,totalpage,total_row;
end

function _M.deleteInfoById(id)
    baseService:checkParamIsNull({id=id});
    local func = function()
        dao.DeleteInfoById(id);
        dao.deleteDetailByInfoId(id);
    end
    local status = dao.txFunction(func)
    return status
end


function _M.getOfficeName(org_id,id)
    local _BaseService = require "new_basep.base.Service.baseinfoService";
    local depresult=_BaseService:depinfo_getOrgTree(org_id);
    for i =1,#depresult do
        if depresult and depresult[i]["id"] == id and depresult[i]["name"] then
            log:debug(depresult[i])
            return depresult[i]["name"]
        else
            return "未找到部门名"
        end
    end
end


function _M.deleteNoComitInfoById(id,org_id,org_type,person_id,identity_id)
    baseService:checkParamIsNull({id=id});
    local func = function()
        dao.deleteNoComitInfoById(id,org_id,org_type,person_id,identity_id);
        dao.deleteDetailByInfoId(id);
    end
    local status = dao.txFunction(func)
    return status
end

function _M.saveToUpload(org_id,org_type,id,person_id,identity_id)
    local result = dao.saveToUpload(org_id,org_type,id,person_id,identity_id)
    return result
end

function _M.findMoneyBySchoolType(stage_type,time_index,start_time,end_time,search_str,page_size,page_num,status,office_id)
    local resultInfo,totalpage,total_row = dao.findMoneyBySchoolType(stage_type,time_index,start_time,end_time,search_str,page_size,page_num,status,office_id)

    for j =1,#resultInfo do
        if resultInfo[j]["org_id"] then
            local aService = require "space.services.PersonAndOrgBaseInfoService"
            local temp = {resultInfo[j]["org_id"]}
            local schoolResults = aService:getSchoolInfoBySchoolids( temp)
            log:debug(schoolResults[1])
            if not schoolResults or not schoolResults[1] or not schoolResults[1]["school_name"] then
                resultInfo[j]["school_name"] = '无'
            else
                local school_name = schoolResults[1]["school_name"]
                resultInfo[j]["school_name"] = tostring(school_name)
            end
            if not schoolResults or not schoolResults[1] or not schoolResults[1]["school_type"] then
                resultInfo[j]["school_type"] = '无'
            else
                local school_type = schoolResults[1]["school_type"]
                resultInfo[j]["school_type"] = tostring(school_type)
            end

        end

    end

    return resultInfo,totalpage,total_row
end

function _M.findMoneyByOffice(time_index,start_time,end_time,page_size,page_num,status,office_id)
local resultInfo,totalpage,total_row = dao.findMoneyByOffice(time_index,start_time,end_time,page_size,page_num,status,office_id)

for j =1,#resultInfo do
    if resultInfo[j]["org_id"] then
        local aService = require "space.services.PersonAndOrgBaseInfoService"
        local temp = {resultInfo[j]["org_id"]}
        local schoolResults = aService:getSchoolInfoBySchoolids( temp)
        log:debug(schoolResults[1])
        if not schoolResults or not schoolResults[1] or not schoolResults[1]["school_name"] then
            resultInfo[j]["school_name"] = '无'
        else
            local school_name = schoolResults[1]["school_name"]
            resultInfo[j]["school_name"] = tostring(school_name)
        end
        if not schoolResults or not schoolResults[1] or not schoolResults[1]["school_type"] then
            resultInfo[j]["school_type"] = '无'
        else
            local school_type = schoolResults[1]["school_type"]
            resultInfo[j]["school_type"] = tostring(school_type)
        end

    end

end

return resultInfo,totalpage,total_row
end

function _M.findInfoByOrgId(org_id,org_type,page_size,page_num,status,start_time,end_time,office_id)
    log:debug(status)
    local resultInfo,total_page,total_row = dao.findInfoByOrgId(org_id,org_type,page_size,page_num,status,start_time,end_time,office_id)
    for j =1,#resultInfo do
        local person_id = resultInfo[j]['person_id']
        local person_res = _util:getPersonInfoByPersonId(person_id)
        if TableUtil:length(person_res)>0 then
            if tostring(person_res[1]["xb_name"])=="userdata: NULL" then
                resultInfo[j]["xb_name"]="男"
            else
                resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            end
--            resultInfo[j]["xb_name"] = tostring(person_res[1]["xb_name"])
            resultInfo[j]["org_name"] = tostring(person_res[1]["org_name"])
            resultInfo[j]["workers_no"] = tostring(person_res[1]["workers_no"])
            resultInfo[j]["person_name"]  = tostring(person_res[1]["person_name"])
        end
        local resultInfo2 = dao.findOfficeInfoByOfficeId(resultInfo[j]["office_id"])
        if TableUtil:length(resultInfo2)>0 then
            resultInfo[j]["office_name"]  = tostring(resultInfo2[1]["office_name"])
        else
            resultInfo[j]["office_name"]  = "无"
        end

        resultInfo[j]["details"] = dao.findInfoDetail(resultInfo[j]["id"])
    end

    return resultInfo,total_page,total_row;
end

function _M.findTotalAndSchool(org_id,org_type,index,start_time,end_time,office_id,time_index)
    local data = ngx.location.capture("/dsideal_yy/subject/getListSemester")
    local _data;
    if data.status ==200 then
        _data = cjson.decode(data.body)
        local xqlist = _data.xqlist
        local inTermstart
        local inTermend
        local inYearstart
        local inYearend
        local inWhatever
        local XN
        local current_year = tonumber(os.date("%Y"))
        local time_table = {}
        if xqlist and TableUtil:length(xqlist) > 0 then
            for i =1 ,#xqlist do
                if xqlist[i]["SFDQXQ"] ==1 then
                    inTermstart = xqlist[i]["KSRQ"]
                    inTermend = xqlist[i]["JSRQ"]
                    XN = xqlist[i]["XN"]
                    if current_year == XN then
                        table.insert(time_table,formatStrtodate(xqlist[i]["KSRQ"]))
                        table.insert(time_table,formatStrtodate(xqlist[i]["JSRQ"]))
                        if not xqlist[i+1] then
                            table.insert(time_table,formatStrtodate(XN.."-12-31"))
                        else
                            table.insert(time_table,formatStrtodate(xqlist[i+1]["KSRQ"]))
                            table.insert(time_table,formatStrtodate(xqlist[i+1]["JSRQ"]))
                        end
                    end

                    inYearstart = os.date("%Y-%m-%d",table_max(time_table)[1])
                    inYearend = os.date("%Y-%m-%d",table_min(time_table)[1])
                end
            end
            local born_time = 0
            local dead_time = 0
            if time_index== 1 then
                born_time = inTermstart.." 00:00:00"
                dead_time = inTermend.." 23:59:59"
            elseif time_index ==2 then
                born_time = inYearstart.." 00:00:00"
                dead_time = inYearend.." 23:59:59"
            elseif time_index ==3 then
                born_time = start_time.." 00:00:00"
                dead_time = end_time.." 23:59:59"
            end                    --前端急着要接口没时间写备注了
            local result
            log:debug(born_time)
            log:debug(dead_time)
--            if whichLevel==1 or whichLevel ==3 then
--                result = dao.getInfoListBydateAndOrg(born_time,dead_time,org_id,org_type)
--            elseif whichLevel == 2 then
--                result = dao.getInfoListBydateAndLevel(born_time,dead_time,office_id)
--            end
--
--            local totalmoney=0
--            for k = 1,#result do
--                totalmoney = totalmoney +result[k]["money"]
--            end
            baseService:checkParamIsNull({
                org_id=org_id,
                org_type=org_type,
                index=index,
                born_time=born_time,
                dead_time=dead_time,
                office_id=office_id
            });
            local result={}
            if index ==1 then
                result["schoolMoney"] =   dao.findSchool(org_id,org_type,born_time,dead_time);
                return result
            elseif index ==2 or index ==3 then

                result["totalMoney"] = dao.findTotalMoney(index,born_time,dead_time,office_id,org_id,org_type);
                result["schoolMoney"] =   dao.findSchool(org_id,org_type,born_time,dead_time);
            end

            return result
--            return totalmoney
        end
    end


end



return baseService:inherit(_M):init()