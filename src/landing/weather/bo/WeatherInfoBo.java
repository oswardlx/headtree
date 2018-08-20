package landing.weather.bo;

import java.io.Serializable;
import java.util.Date;

public class WeatherInfoBo implements Serializable {
    private String date ;
    private String area_code;
    private String weather;
    private String temperature;
    private String wind_direction;
    private String wind_Power;
    private String sun_begin_end;
    private String city_name;

    public WeatherInfoBo(String date, String area_code, String weather, String temperature, String wind_direction, String wind_Power, String city_name) {
        this.date = date;
        this.area_code = area_code;
        this.weather = weather;
        this.temperature = temperature;
        this.wind_direction = wind_direction;
        this.wind_Power = wind_Power;
        this.city_name = city_name;
    }

    public String getCity_name() {
        return city_name;
    }

    public void setCity_name(String city_name) {
        this.city_name = city_name;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getArea_code() {
        return area_code;
    }

    public void setArea_code(String area_code) {
        this.area_code = area_code;
    }

    public String getWeather() {
        return weather;
    }

    public void setWeather(String weather) {
        this.weather = weather;
    }

    public String getTemperature() {
        return temperature;
    }

    public void setTemperature(String temperature) {
        this.temperature = temperature;
    }

    public String getWind_direction() {
        return wind_direction;
    }

    public void setWind_direction(String wind_direction) {
        this.wind_direction = wind_direction;
    }

    public String getWind_Power() {
        return wind_Power;
    }

    public void setWind_Power(String wind_Power) {
        this.wind_Power = wind_Power;
    }

    public String getSun_begin_end() {
        return sun_begin_end;
    }

    public void setSun_begin_end(String sun_begin_end) {
        this.sun_begin_end = sun_begin_end;
    }
}
