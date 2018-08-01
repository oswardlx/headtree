--
-- Created by IntelliJ IDEA.
-- User: 91946
-- Date: 2017/11/16
-- Time: 11:35
-- To change this template use File | Settings | File Templates.
--
local baseDao = require("social.dao.CommonBaseDao")
local DBUtil = require "social.common.mysqlutil";
local log = require("social.common.log4j"):new()
local TableUtil = require("social.common.table")
local quote = ngx.quote_sql_str
local _M = {}

local function computePage(count, page_size, page_num)
    local _page_num = page_num;
    local Page = math.floor((count + page_size - 1) / page_size)
    if Page > 0 and page_num > Page then
        page_num = Page
    end

    local offset = page_size * page_num - page_size
    if _page_num > Page then
        return Page, 10000000
    end

    return Page, offset
end

function _M.addExaminaPerson(param)
    local column = {}
    local values = {}
    log:debug(param)
    for key, var in pairs(param) do
        if param[key] and tostring(param[key]) ~= "userdata: NULL" then
            table.insert(column, key)
            table.insert(values, quote(var))
        end
    end
    local templet = "INSERT INTO `%s` (`%s`) VALUES (%s)"
    local sql = templet:format("T_SOCIAL_EXAMINE_PERSON", table.concat(column, "`,`"), table.concat(values, ","))
    log:debug(sql);
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.insert_id > 0 then
        return true, result.insert_id
    end
    error("addExaminaPerson fail.")


end


function _M.addExaminaRequest(param)
    local column = {}
    local values = {}
    for key, var in pairs(param) do
        if param[key] and tostring(param[key]) ~= "userdata: NULL" then
            table.insert(column, key)
            table.insert(values, quote(var))
        end
    end
    local templet = "INSERT INTO `%s` (`%s`) VALUES (%s)"
    local sql = templet:format("T_SOCIAL_EXAMINE_INFO", table.concat(column, "`,`"), table.concat(values, ","))
    local db = DBUtil:getDb();
    log:debug(sql)
    local result = db:query(sql)
    if result and result.insert_id > 0 then
        return true, result.insert_id
    end
    error("addExaminaRequest fail.")
end

function _M.addExaminaRequestDetail(param)
    local column = {}
    local values = {}
    for key, var in pairs(param) do
        if param[key] and tostring(param[key]) ~= "userdata: NULL" then
            table.insert(column, key)
            table.insert(values, quote(var))
        end
    end
    local templet = "INSERT INTO `%s` (`%s`) VALUES (%s)"
    local sql = templet:format("T_SOCIAL_EXAMINE_DETAIL", table.concat(column, "`,`"), table.concat(values, ","))
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.insert_id > 0 then
        return true, result.insert_id
    end
    error("addExaminaRequestDetail fail.")
end



function _M.removeExaminaPerson(id)
    local sql = "DELETE FROM T_SOCIAL_EXAMINE_PERSON Where id =" .. quote(id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result or result.affected_rows <= 0 then
        return false
    end
    return true
end

function _M.findExaminaDeptPerson(office_id)
    local sql = "SELECT * FROM T_SOCIAL_EXAMINE_PERSON Where office_id = " .. quote(office_id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result then
        result = false
    end
    return result
end

function _M.findExaminaOfficePerson(office_id)
    local sql = "SELECT * FROM T_SOCIAL_EXAMINE_PERSON Where office_id = " .. quote(office_id) .. " and level = 2"
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result then
        result = false
    end
    return result
end

function _M.findExaminaExDeptPerson(level, org_id, org_type)
    local sql = "SELECT * FROM T_SOCIAL_EXAMINE_PERSON Where level = " .. quote(level) .. " and org_id = " .. quote(org_id) .. " and org_type= " .. quote(org_type)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result then
        result = false
    end
    return result
end

function _M.addExaminaOffice(param)
    local column = {}
    local values = {}
    for key, var in pairs(param) do
        if param[key] and tostring(param[key]) ~= "userdata: NULL" then
            table.insert(column, key)
            table.insert(values, quote(var))
        end
    end
    local templet = "INSERT INTO `%s` (`%s`) VALUES (%s)"
    local sql = templet:format("T_SOCIAL_EXAMINE_OFFICE", table.concat(column, "`,`"), table.concat(values, ","))
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.insert_id > 0 then
        return true, result.insert_id
    end
    return false
end

function _M.removeExaminaOffice(office_id)
    local sql = "UPDATE T_SOCIAL_EXAMINE_OFFICE SET is_del = 1 Where id = " .. quote(office_id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result or result.affected_rows <= 0 then
        error("removeExaminaOffice fail.")
    end
    return true
end

function _M.removeExaminaPersonByOfficeId(office_id)
    local sql = "DELETE FROM T_SOCIAL_EXAMINE_PERSON Where office_id = " .. quote(office_id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result then
        return false
    end
    return true
end

function _M.findExaminaDept(org_id, org_type)
    local sql = "SELECT * FROM T_SOCIAL_EXAMINE_OFFICE WHERE org_id = " .. quote(org_id) .. " and org_type = " .. quote(org_type).." and is_del  = 0"
    local db = DBUtil:getDb();
    local result = db:query(sql)
    return result
end


function _M.findExaminaOfficePersonByOfficeId(id)
    local sql = "SELECT * FROM T_SOCIAL_EXAMINE_PERSON WHERE office_id=" .. quote(id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    return result
end

local function showExCount(status, org_id, org_type, search_str)
    local sql_count
    if not search_str then
        sql_count = " select COUNT(DISTINCT a.id) as Row From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = " .. status .. " and a.org_id = " .. org_id .. " and a.org_type = " .. org_type .. " and  EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level =1)"
    else
        sql_count = " select COUNT(DISTINCT a.id) as Row From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = " .. status .. " and a.org_id = " .. org_id .. " and a.org_type = " .. org_type .. " and  EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level =1)" .. " and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')"
    end
    local result = DBUtil:querySingleSql(sql_count);
    log:debug(result)
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function showExList(status, org_id, org_type, offset, page_size, search_str)
    local sql
    local search_value_c = (search_str and string.len(search_str) > 0) and "and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')" or ""
    sql = "select DISTINCT a.* From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = %d and a.org_id = %d and a.org_type = %d and  EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level =1 ) %s order by a.create_time DESC limit %d,%d;"
    sql = string.format(sql, status, org_id, org_type, search_value_c, offset, page_size)
    local result = DBUtil:querySingleSql(sql);
    return result;
end

local function showExCountMaster(status, search_str)
    local sql_count
    if not search_str then
        sql_count = "select COUNT(DISTINCT a.id) as Row From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = " .. status .. " and  EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level =3)  "
    else
        sql_count = "select COUNT(DISTINCT a.id) as Row From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = " .. status .. " and  EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level =3) and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%') "
    end
    local result = DBUtil:querySingleSql(sql_count);
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function showExListMaster(status, offset, page_size, search_str)
    local sql
    if not search_str then
        sql = "select DISTINCT a.*  From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = " .. status .. " and  EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level =3) order by a.create_time DESC limit " .. offset .. "," .. page_size .. ";"
    else
        sql = "select DISTINCT a.*  From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = " .. status .. " and  EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level =3)  and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')" .. "  order by a.create_time DESC limit " .. offset .. "," .. page_size .. ";"
    end
    local result = DBUtil:querySingleSql(sql);
    return result;
end

function _M.findExaminaInfoExOfficeByStatus(status, org_id, org_type, page_size, page_num, search_str)
    if org_id == 0 and org_type == 0 then
        local count = showExCountMaster(status);
        local list = {}
        local _page = 0
        local offset = 0
        if count and tonumber(count) > 0 then
            _page, offset = computePage(count, page_size, page_num);
            log:debug(offset)
            list = showExListMaster(status, offset, page_size);
        end
        return list, _page, #list
    else
        local count = showExCount(status, org_id, org_type, search_str);
        local list = {}
        local _page = 0
        local offset = 0
        if count and tonumber(count) > 0 then
            _page, offset = computePage(count, page_size, page_num);
            log:debug(offset)
            list = showExList(status, org_id, org_type, offset, page_size, search_str);
        end
        return list, _page, #list
    end
end

local function showCount(status, office_id)
    local sql_count = "select COUNT(DISTINCT a.id) as Row From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = " .. status .. " and a.office_id= " .. office_id .. " and  EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level =2)"
    local result = DBUtil:querySingleSql(sql_count);
    log:debug(result)
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function showList(status, office_id, offset, page_size)
    local sql = "select DISTINCT a.* From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = " .. status .. " and a.office_id= " .. office_id .. " and  EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level =2) order by a.create_time DESC limit %d,%d;"
    log:debug(sql)
    log:debug(offset)
    log:debug(page_size)
    sql = string.format(sql, offset, page_size)
    local result = DBUtil:querySingleSql(sql);

    return result;
end




function _M.findExaminaInfoOfficeByStatus(status, office_id, page_size, page_num)
    local count = showCount(status, office_id);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);
        list = showList(status, office_id, offset, page_size);
    end
    log:debug(list)
    return list, _page, #list
end


local function showTeacherCount(person_id, status, org_id, org_type, search_str)
    local sql_count
    if status == 5 then --全部
        sql_count = "select count(id) as Row from T_SOCIAL_EXAMINE_INFO where person_id = " .. quote(person_id) .. " and org_id = " .. quote(org_id) .. " and org_type= " .. quote(org_type) .. " and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')"
    else
        sql_count = " select  count(id) as Row  from T_SOCIAL_EXAMINE_INFO where status = " .. quote(status) .. " and person_id =" .. quote(person_id) .. " and org_id = " .. quote(org_id) .. " and org_type= " .. quote(org_type) .. " and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')"
    end
    local result = DBUtil:querySingleSql(sql_count);
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function showTeacherList(person_id, status, org_id, org_type, offset, page_size, search_str)
    log:debug("showTeacherlist")
    local sql
    local appendsql = " and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')"
    if status == 5 then
        sql = "select * From T_SOCIAL_EXAMINE_INFO WHERE person_id =" .. quote(person_id) .. " and org_id = " .. quote(org_id) .. " and org_type= " .. quote(org_type) .. " %s order by create_time DESC limit %d,%d;"
        sql = string.format(sql, appendsql, offset, page_size)
    else
        sql = "select * From T_SOCIAL_EXAMINE_INFO WHERE status = " .. quote(status) .. " and person_id =" .. quote(person_id) .. " and org_id = " .. quote(org_id) .. " and org_type= " .. quote(org_type) .. " %s order by create_time DESC limit %d,%d;"
        sql = string.format(sql, appendsql, offset, page_size)
    end
    local result = DBUtil:querySingleSql(sql);
    return result;
end

function _M.teacherFindInfoByStatus(person_id, status, org_id, org_type, page_num, page_size, search_str)
    log:debug("dao.teacherfindinfobyStatus")
    local count = showTeacherCount(person_id, status, org_id, org_type, search_str);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);
        log:debug('pagesize:' .. page_size)
        list = showTeacherList(person_id, status, org_id, org_type, offset, page_size, search_str);
    end
    return list, _page, #list
end

function _M.findInfoDetail(info_id)
    local sql = "SELECT * FROM T_SOCIAL_EXAMINE_DETAIL WHERE INFO_ID = " .. quote(info_id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    return result
end

function _M.dealExaminaRequest(param)
    local column = {}
    local values = {}
    for key, var in pairs(param) do
        if param[key] and tostring(param[key]) ~= "userdata: NULL" then
            table.insert(column, key)
            log:debug(var)
            table.insert(values, quote(var))
        end
    end
    local templet = "INSERT INTO `%s` (`%s`) VALUES (%s)"
    local sql = templet:format("T_SOCIAL_EXAMINE_STATUS", table.concat(column, "`,`"), table.concat(values, ","))
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.insert_id > 0 then
        return true, result.insert_id
    end
    error("dealExaminaRequest failed.")
end

function _M.getPersonInfo(person_id, identity_id, org_id, org_type)
    local sql = "SELECT * FROM T_SOCIAL_EXAMINE_PERSON where person_id = " .. quote(person_id) .. " and identity_id =" .. quote(identity_id) .. " and org_id = " .. quote(org_id) .. " and org_type = " .. quote(org_type)
    local db = DBUtil:getDb();
    log:debug(sql)
    local result = db:query(sql)
    return result
end

local function showHavenotCount1(level, org_id, org_type)
    local sql_count = " select  count(a.id) as Row  from t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id where a.status = 1 and a.org_id =" .. org_id .. " and a.org_type=" .. org_type .. " and NOT EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level = " .. level .. ")"

    local result = DBUtil:querySingleSql(sql_count);
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function showHavenotList1(level, offset, page_size, org_id, org_type)
    local sql = "select a.* From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = 1 and a.org_id = " .. org_id .. " and a.org_type = " .. org_type .. "  and NOT EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level = " .. level .. ")" .. " order by a.create_time DESC limit %d,%d;"
    sql = string.format(sql, offset, page_size)
    local result = DBUtil:querySingleSql(sql);
    return result;
end

function _M.findHavenotExaminaInfo1(level, page_size, page_num, org_id, org_type)
    local count = showHavenotCount1(level, org_id, org_type);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);
        log:debug('offset:' .. offset, 'page_size:' .. page_size)
        list = showHavenotList1(level, offset, page_size, org_id, org_type);
    end
    return list, _page, #list
end

local function showHavenotCount2(level, office_id)
    local prelevel = level - 1
    local sql_count = "SELECT count(a.id) as Row FROM t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id where a.office_id =" .. office_id .. " and  a.status =1 and level = " .. prelevel .. " and NOT EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level = " .. level .. ")"

    local result = DBUtil:querySingleSql(sql_count);
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function showHavenotList2(level, offset, page_size, office_id)
    local prelevel = level - 1
    local sql = "select a.* From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = 1 and level = " .. prelevel .. " and office_id = " .. office_id .. "  and NOT EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level = " .. level .. ")" .. " order by a.create_time DESC limit %d,%d;"
    sql = string.format(sql, offset, page_size)
    local result = DBUtil:querySingleSql(sql);
    return result;
end

function _M.findHavenotExaminaInfo2(level, page_size, page_num, office_id)
    local count = showHavenotCount2(level, office_id);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);
        log:debug('offset:' .. offset, 'page_size:' .. page_size)
        list = showHavenotList2(level, offset, page_size, office_id);
    end
    return list, _page, #list
end

local function showHavenotCount3(level)
    local prelevel = level - 1
    local sql_count = "SELECT count(a.id) as Row FROM t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id where   a.status =1 and level = " .. prelevel .. " and NOT EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level = " .. level .. ")"

    local result = DBUtil:querySingleSql(sql_count);
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function showHavenotList3(level, offset, page_size)
    local prelevel = level - 1
    local sql = "select a.* From t_social_examine_info a left join t_social_examine_status b on  a.id=b.info_id WHERE a.status = 1  and level = " .. prelevel .. "  and NOT EXISTS ( SELECT * FROM t_social_examine_status c where a.id = c.info_id and level = " .. level .. ")" .. " order by a.create_time DESC limit %d,%d;"
    sql = string.format(sql, offset, page_size)
    local result = DBUtil:querySingleSql(sql);
    return result;
end

function _M.findHavenotExaminaInfo3(level, page_size, page_num, office_id)
    local count = showHavenotCount3(level);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);

        log:debug('offset:' .. offset, 'page_size:' .. page_size)
        log:debug("_page:" .. _page, 'count:' .. count)
        list = showHavenotList3(level, offset, page_size);
    end
    return list, _page, #list
end


function _M.findOfficeInfoByOfficeId(office_id)
    local sql = "Select * FROM T_SOCIAL_EXAMINE_Office where  id =" .. quote(office_id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    return result
end

function _M.findRequestInfo(id)
    local sql = "SELECT * FROM T_SOCIAL_EXAMINE_INFO where id = " .. quote(id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    return result
end

function _M.findStatusInfo(info_id)
    local sql = "SELECT level,status,e_p_id,remarks FROM T_social_examine_status where info_id = " .. quote(info_id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    for i = 1, 3 do
        if result[i] == nil then
            result[i] = {}
            result[i]["level"] = i
            result[i]["status"] = 0
        end
    end
    return result
end

function _M.disagree(info_id)
    local sql = "UPDATE T_SOCIAL_EXAMINE_INFO  SET status = 3 where id = " .. info_id
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.affected_rows > 0 then
        return true
    end
    error("disagree failed.")
end

function _M.complete(info_id)
    local sql = "UPDATE T_SOCIAL_EXAMINE_INFO  SET status = 2 where id = " .. info_id
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.affected_rows > 0 then
        return true
    end
    error("complete failed.")
end

--其实这里不用quote，因为这些在接收的时候就判断是否是数字了
function _M.cancleRequest(org_id, org_type, info_id)
    local sql = "UPDATE T_SOCIAL_EXAMINE_INFO  SET status = 4 where status =1 and id = " .. info_id .. " and org_id = " .. org_id .. " and org_type = " .. org_type
    local db = DBUtil:getDb();
    local result = db:query(sql)
    log:debug(result)
    if result and result.affected_rows > 0 then
        return true
    end
    error("cancleRequest failed")
end

function _M.getInfoListBydateAndOrg(born_time, dead_time, org_id, org_type)
    local sql = "select money from t_social_examine_info where org_id = " .. org_id .. " and org_type = " .. org_type .. " and create_time between '" .. born_time .. "' and '" .. dead_time .. "'"
    local db = DBUtil:getDb();
    log:debug(sql)
    local result = db:query(sql)
    return result
end

function _M.getInfoListBydateAndLevel(born_time, dead_time, office_id)
    local sql = "select money from t_social_examine_info where office_id =  " .. office_id .. " and create_time between '" .. born_time .. "' and '" .. dead_time .. "'"
    local db = DBUtil:getDb();
    local result = db:query(sql)
    return result
end

function _M.updateInfo(param)
    log:debug(param)
    local column = {}
    local values = {}
    for key, var in pairs(param) do
        if param[key] and tostring(param[key]) ~= "userdata: NULL" then
            table.insert(column, key .. "=" .. quote(var))
        end
    end
    local templet = "UPDATE %s set %s where id =  %s "
    local sql = templet:format("T_SOCIAL_EXAMINE_INFO", table.concat(column, ","), param.id)
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.affected_rows >= 0 then
        return true, param.id
    end
    error("updateInfo failed")
end

function _M.updateDetil(detail)
    local result2
    local result1
    if detail['id'] then
        local column = {}
        local values = {}
        for key, var in pairs(detail) do
            if detail[key] and tostring(detail[key]) ~= "userdata: NULL" then
                table.insert(column, key .. "=" .. quote(var))
            end
        end
        local templet = "update %s set %s where id =  %s "
        local sql = templet:format("T_SOCIAL_EXAMINE_DETAIL", table.concat(column, ","), detail.id)
        local db = DBUtil:getDb();
        result1 = db:query(sql)
    else
        result2 = _M.addExaminaRequestDetail(detail);
    end
    if result1 or result2 then
        return true
    end
    return false
end

function _M.deleteDetailByInfoId(info_id)
    local sql = "DELETE FROM t_social_examine_detail where INFO_ID = " .. info_id
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result or result.affected_rows <= 0 then
        error("DELETE t_social_examine_detail fail.")
    end
end

function _M.findDaySequence()
    local sql = "SELECT CASE WHEN LPAD(day_sequence,6,'0') IS NULL THEN LPAD(1,6,'0') ELSE LPAD(day_sequence+1,6,'0') END  as _day_sequence FROM t_social_examine_info WHERE DATE_FORMAT(create_time,'%Y-%m-%d')= DATE_FORMAT(NOW(),'%Y-%m-%d') ORDER BY create_time DESC LIMIT 1 "
    local db = DBUtil:getDb();
    local result = db:query(sql)
    log:debug(result)
    log:debug(result[1])
    if result and TableUtil:length(result) > 0 then
        return result[1]['_day_sequence']
    end
    return "000001"
end

local function findExaminaInfoByCodeCount(org_id, org_type, search_str,status)
    local sql_count
    local addsql = " and status <> 0 "
    if status ~=5 then
        addsql = " and status = "..status
    end
    if not search_str then
        sql_count = "select COUNT(DISTINCT id) as Row From t_social_examine_info WHERE 1= 1 "..addsql.."  and org_id = " .. org_id .. " and org_type = " .. org_type
    else
        sql_count = "select COUNT(DISTINCT id) as Row From t_social_examine_info  WHERE 1= 1 "..addsql.." and org_id = " .. org_id .. " and org_type = " .. org_type .. " and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')"

    end
    log:debug(sql_count)
    local result = DBUtil:querySingleSql(sql_count);
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function findExaminaInfoByCodeList(org_id, org_type, page_num, page_size, search_str, offset,status)
    local sql
    local addsql = " and status <> 0 "
    if status ~=5 then
        addsql = " and  status = "..status
    end
    if not search_str then
        sql = "select  *  From t_social_examine_info  WHERE 1= 1 "..addsql.." and org_id = " .. org_id .. " and org_type = " .. org_type .. " order by create_time DESC limit " .. offset .. "," .. page_size .. ";"
    else
        sql = "select  *  From t_social_examine_info  WHERE 1= 1 "..addsql.." and org_id = " .. org_id .. " and org_type = " .. org_type .. " and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')" .. "  order by create_time DESC limit " .. offset .. "," .. page_size .. ";"
    end
    log:debug(sql)

    local result = DBUtil:querySingleSql(sql);
    return result;
end

function _M.findExaminaInfoByCode(org_id, org_type, page_num, page_size, search_str,status)
    local count = findExaminaInfoByCodeCount(org_id, org_type, search_str,status);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);

        list = findExaminaInfoByCodeList(org_id, org_type, page_num, page_size, search_str, offset,status);
    end
    return list, _page, #list

    --    local sql = "SELECT * FROM T_SOCIAL_EXAMINE_INFO where status = id = "..quote(code)
    --    local db = DBUtil:getDb();
    --    local result = db:query(sql)
    --    return result
end

function _M.DeleteInfoById(id)
    local sql = "DELETE FROM t_social_examine_info where id = " .. id
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.affected_rows > 0 then
        return true
    end
    error("DeleteInfoById failed")
end

function _M.deleteNoComitInfoById(id, org_id, org_type, person_id, identity_id)
    local sql = "DELETE FROM t_social_examine_info where id = " .. id .. " and org_id =" .. org_id .. " and org_type = " .. org_type .. " and status = 0 " .. " and person_id = " .. person_id .. " and identity_id = " .. identity_id
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if not result or result.affected_rows <= 0 then
        error("delete t_social_examine_info fail.")
    end
end

function _M.saveToUpload(org_id, org_type, id, person_id, identity_id)
    local sql = "update t_social_examine_info set status = 1 where org_id = " .. org_id .. " and org_type = " .. org_type .. " and id = " .. id .. " and person_id = " .. person_id .. " and identity_id = " .. identity_id .. " and status = 0 "
    local db = DBUtil:getDb();
    local result = db:query(sql)
    if result and result.affected_rows > 0 then
        return true
    end
    return false
end

local function findMoneyBySchoolTypeCount(stage_type,time_index,start_time,end_time,search_str,status,office_id)
    local addsql1 = ""
    local addsql2 = ""
    local addsql3 = ""
    local addsql4 = ""
    local addsql5 = " org_id,org_type "
    local addsql6 = ""
    if office_id ~=-1 then
        addsql6 = " and office_id = "..office_id
    end
    if status ~=5 then
        addsql4 = " and status = "..status
    end
    if stage_type ~=0 then
        addsql1 = " and stage_type = "..stage_type
--        addsql5 = " stage_type "
    end
    if start_time~='0' and end_time~='0' then
        start_time = start_time.." 00:00:00"
        end_time = end_time.." 23:59:59"
        addsql2 = " and create_time between '" .. start_time .. "' and '" .. end_time.."' "
    end
    addsql3 = " and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')"

    local sql_count = " Select count(org_id) as Row from (Select "..addsql5..",SUM(money) from t_social_examine_info a where 1=1 and status <> 0 "..addsql6..addsql1..addsql3..addsql4..addsql2.." GROUP BY "..addsql5.."   ) b"
    log:debug(sql_count)
    local result = DBUtil:querySingleSql(sql_count);
    log:debug(result)
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function findMoneyBySchoolTypeList(stage_type,time_index,start_time,end_time,search_str,page_size,offset,status,office_id)
    local addsql1 = ""
    local addsql2 = ""
    local addsql3 = ""
    local addsql4 =""
    local addsql5 = " org_id,org_type "
    local addsql6 = ""
    if office_id ~=-1 then
        addsql6 = " and office_id = "..office_id
    end
    if status ~=5  then
        addsql4 = " and status = "..status
    end
    if stage_type ~=0 then
        addsql1 = " and stage_type = "..stage_type
--        addsql5 = " stage_type "
    end
    if start_time~='0' and end_time~='0' then
        start_time = start_time.." 00:00:00"
        end_time = end_time.." 23:59:59"
        addsql2 = " and create_time between '" .. start_time .. "' and '" .. end_time.."' "
    end
    addsql3 = " and (project_code like '%" .. search_str .. "%' or project_name like '%" .. search_str .. "%')"

    local sql = "select "..addsql5..",Sum(money) as sum From t_social_examine_info WHERE  1=1 and status <> 0 "..addsql1..addsql6..addsql2..addsql3..addsql4 .." group By "..addsql5.." order by create_time DESC limit "..offset..","..page_size..";"
    log:debug(sql)
    local result = DBUtil:querySingleSql(sql);
    return result;
end

function _M.findMoneyBySchoolType(stage_type,time_index,start_time,end_time,search_str,page_size,page_num,status,office_id)
    local count = findMoneyBySchoolTypeCount(stage_type,time_index,start_time,end_time,search_str,status,office_id);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);
        list = findMoneyBySchoolTypeList(stage_type,time_index,start_time,end_time,search_str,page_size,offset,status,office_id);
    end
    return list, _page, #list
end

local function findMoneyByOfficeCount(time_index,start_time,end_time,status,office_id)
    local addsql2 = ""
    local addsql3 = ""
    local addsql4 = ""
    local addsql5 = " org_id,org_type "
    if status ~=5 then
        addsql4 = " and status = "..status
    end
    if start_time~='0' and end_time~='0' then
        start_time = start_time.." 00:00:00"
        end_time = end_time.." 23:59:59"
        addsql2 = " and create_time between '" .. start_time .. "' and '" .. end_time.."' "
    end

    local sql_count = " Select count(org_id) as Row from (Select "..addsql5..",SUM(money) from t_social_examine_info a where 1=1 and office_id= "..office_id.." and status <> 0 "..addsql3..addsql4..addsql2.." GROUP BY "..addsql5.."   ) b"
    log:debug(sql_count)
    local result = DBUtil:querySingleSql(sql_count);
    log:debug(result)
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function findMoneyByOfficeList(time_index,start_time,end_time,page_size,offset,status,office_id)
    local addsql1 = ""
    local addsql2 = ""
    local addsql3 = ""
    local addsql4 =""
    local addsql5 = " org_id,org_type "
    if status ~=5  then
        addsql4 = " and status = "..status
    end
    if start_time~='0' and end_time~='0' then
        start_time = start_time.." 00:00:00"
        end_time = end_time.." 23:59:59"
        addsql2 = " and create_time between '" .. start_time .. "' and '" .. end_time.."' "
    end

    local sql = "select "..addsql5..",Sum(money) as sum From t_social_examine_info WHERE  1=1 and office_id= "..office_id.." and status <> 0 "..addsql1..addsql2..addsql3..addsql4 .." group By "..addsql5.." order by create_time DESC limit "..offset..","..page_size..";"
    log:debug(sql)
    local result = DBUtil:querySingleSql(sql);
    return result;
end

function _M.findMoneyByOffice(time_index,start_time,end_time,page_size,page_num,status,office_id)
    local count = findMoneyByOfficeCount(time_index,start_time,end_time,status,office_id);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);
        list = findMoneyByOfficeList(time_index,start_time,end_time,page_size,offset,status,office_id);
    end
    return list, _page, #list
end

local function findInfoByOrgIdCount(org_id,org_type,status,start_time,end_time,office_id)
    local addsql2 = ""
    local addsql3 = ""
    local addsql4 = ""
    local addsql5 = " org_id "
    local addsql6 = ""
    if office_id~=-1 then
        addsql6 = " and office_id = "..office_id
    end
    if status ~=5 then
        addsql4 = " and status = "..status
    end
    if start_time~='0' and end_time~='0' then
        start_time = start_time.." 00:00:00"
        end_time = end_time.." 23:59:59"
        addsql2 = " and create_time between '" .. start_time .. "' and '" .. end_time.."' "
    end
    local sql_count = "select count(DISTINCT id) as Row from t_social_examine_info where status<>0 "..addsql4..addsql6.." and  org_id = "..org_id.." and org_type = "..org_type..addsql2
--    local sql_count = " Select count("..addsql5..") as Row from (Select "..addsql5..",SUM(money) from t_social_examine_info a where 1=1 and office_id= "..office_id.." and status <> 0 "..addsql3..addsql4..addsql2.." GROUP BY "..addsql5.."   ) b"
    log:debug(sql_count)
    local result = DBUtil:querySingleSql(sql_count);
    log:debug(result)
    if result and result[1] then
        return result[1]['Row']
    end
    return 0;
end

local function findInfoByOrgIdList(org_id,org_type,page_size,offset,status,start_time,end_time,office_id)
    local addsql1 = ""
    local addsql2 = ""
    local addsql3 = ""
    local addsql4 =""
    local addsql5 = " org_id "
    local addsql6 = ""
    if office_id~=-1 then
        addsql6 = " and office_id = "..office_id
    end
    if status ~=5  then
        addsql4 = " and status = "..status
    end
    if start_time~='0' and end_time~='0' then
        start_time = start_time.." 00:00:00"
        end_time = end_time.." 23:59:59"
        addsql2 = " and create_time between '" .. start_time .. "' and '" .. end_time.."' "
    end
    local sql = "select * from t_social_examine_info where status<>0 "..addsql4..addsql6.." and  org_id = "..org_id.." and org_type = "..org_type..addsql2.." order by create_time DESC limit "..offset..","..page_size..";"
--    local sql = "select "..addsql5..",Sum(money) as sum From t_social_examine_info WHERE  1=1 and office_id= "..office_id.." and status <> 0 "..addsql1..addsql2..addsql3..addsql4 .." group By "..addsql5.." order by create_time DESC limit "..offset..","..page_size..";"
    log:debug(sql)
    local result = DBUtil:querySingleSql(sql);
    return result;
end

function _M.findInfoByOrgId(org_id,org_type,page_size,page_num,status,start_time,end_time,office_id)
    local count = findInfoByOrgIdCount(org_id,org_type,status,start_time,end_time,office_id);
    local list = {}
    local _page = 0
    local offset = 0
    if count and tonumber(count) > 0 then
        _page, offset = computePage(count, page_size, page_num);
        list = findInfoByOrgIdList(org_id,org_type,page_size,offset,status,start_time,end_time,office_id);
    end
    return list, _page, #list
end

function _M.findExaminePersonById(person_id,identity_id)
    local sql = "Select id from t_social_examine_person where person_id = "..person_id.." and identity_id = "..identity_id;
    local db = DBUtil:getDb();
    local result = db:query(sql)
    log:debug(result)
    if result and TableUtil:length(result) > 0 then
        error(" findExaminePersonById fail.")
    end

end

function _M.getTFdealRequest(info_id,level)
    local sql = "Select status from t_social_examine_status where info_id = "..info_id.." and level = "..level
    local db = DBUtil:getDb();
    local result = db:query(sql)
    return result
end

function _M.findTotalMoney(index,start_time,end_time,office_id,org_id,org_type)
    local sql =" "
    local addsql2 = ""

    if start_time~='0' and end_time~='0' then
        start_time = start_time
        end_time = end_time
        addsql2 = " and create_time between '" .. start_time .. "' and '" .. end_time.."' "
    end
    if index ==2 then
        sql = "Select Sum(money) money from t_social_examine_info where status = 2 and office_id = "..office_id..addsql2
    elseif index == 3 then
        sql = "Select Sum(money) money from t_social_examine_info where status = 2 "..addsql2
    end
    local db = DBUtil:getDb();
    log:debug("totalsql:"..sql)
    local result = db:query(sql)
    log:debug(result[1]['money'])
    if result[1]['money'] and tostring(result[1]['money']) == "userdata: NULL" then
        result[1]['money']='0'
    end
    if not result or TableUtil:length(result) == 0 then
        return "获取数据失败"
    end
    return result
end

function _M.findSchool(org_id,org_type,start_time,end_time)
    local addsql2 = ""
    if start_time~='0' and end_time~='0' then
        start_time = start_time
        end_time = end_time
        addsql2 = " and create_time between '" .. start_time .. "' and '" .. end_time.."' "
    end
    local sql = "Select SUM(money) money from t_social_examine_info where status = 2 and org_id = "..org_id.." and org_type = "..org_type..addsql2
    local db = DBUtil:getDb();
    log:debug("schoolsql:"..sql)

    local result = db:query(sql)
    log:debug(result)

    if result[1]['money'] and tostring(result[1]['money']) == "userdata: NULL" then
        result[1]['money']='0'
    end
    if not result or TableUtil:length(result) == 0 then
        return "获取数据失败"
    end
    return result
end

return baseDao:inherit(_M):init()
