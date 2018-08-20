package landing.weather.controller;

import com.landing.weather.service.GetWeatherService;
import com.landing.weather.util.RespFormat;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.annotation.Resource;
import java.io.Serializable;

@Controller
@RequestMapping(value = "/weather")
public class GetWeatherCtl2 implements Serializable {
    @Resource(name="getWeatherService")
    private GetWeatherService getWeatherService;
    @Resource(name = "RespFormat")
    private RespFormat respFormat;
    @RequestMapping(value = "/get_weather7.landing" ,method = RequestMethod.GET)
    public String GetWeatherController(String AreaCode, ModelMap modelMap){
        String city_id =AreaCode;
        if(AreaCode ==null){
            modelMap.addAttribute("result",respFormat.FailReturn("未传入AreaCode").toString());
            return "weather";
        }

//        GetWeatherService getWeatherService = new GetWeatherService();
        JSONArray jsonArray = null;
        String message = "成功";
        String success="true";

        try {
            jsonArray = getWeatherService.get_weahter_info(city_id);
            System.out.println(jsonArray.toString());
        } catch (Exception e) {
            message = e.getMessage();
            success = "false";
            e.printStackTrace();
        }
        JSONObject jo = new JSONObject();
        try {
            jo.put("success",success);
            jo.put("result",jsonArray);
            jo.put("info",message);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        modelMap.addAttribute("result",jo.toString());
        return "weather";
    }
}
