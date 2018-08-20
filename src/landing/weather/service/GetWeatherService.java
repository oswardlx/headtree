package landing.weather.service;

import com.landing.weather.bo.WeatherInfoBo;
import com.landing.weather.util.WeatherReptile;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Service;


import java.io.Serializable;
import java.util.List;

@Service("getWeatherService")
public class GetWeatherService implements Serializable {
    public JSONArray get_weahter_info (String city_code) throws Exception{
        String url = "http://www.weather.com.cn/weather/"+city_code+".shtml";
        WeatherReptile weatherReptile = new WeatherReptile();
        List<WeatherInfoBo> weatherInfoBoList =  weatherReptile.getWeather(url,city_code);
        JSONArray jsonArray = new JSONArray();
        for(WeatherInfoBo weatherInfoBo:weatherInfoBoList){
            JSONObject jo = new JSONObject();
            jo.put("CityName",weatherInfoBo.getCity_name());
            jo.put("AreaCode",weatherInfoBo.getArea_code());
            jo.put("HisWeatherDate",weatherInfoBo.getDate());
            jo.put("Weather",weatherInfoBo.getWeather());
            jo.put("Temperature",weatherInfoBo.getTemperature());
            jo.put("WindDirection",weatherInfoBo.getWind_direction());
            jo.put("WindPower",weatherInfoBo.getWind_Power());
            jsonArray.put(jo);
        }
        return jsonArray;
    }
}
