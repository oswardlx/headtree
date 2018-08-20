package landing.weather.util;


import com.landing.weather.bo.WeatherInfoBo;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.*;


public class WeatherReptile implements Serializable {
    public List<WeatherInfoBo> getWeather(String weatherUrl, String AreaCode) {
        String userAgent = UserAgentUtil.getUserAgents();
        try {
            Document doc = null;
            WeatherReptile weather_reptile = new WeatherReptile();
            doc = Jsoup.connect(weatherUrl).userAgent(userAgent).timeout(60000).get();

            Elements a = doc.getElementsByClass("t clearfix").get(0).getElementsByTag("li");
            Element a2 = null;
            try {
                a2 = doc.getElementsByClass("crumbs fl").get(0).getElementsByTag("a").get(1);
            } catch (Exception e) {
                e.printStackTrace();
                a2 = doc.getElementsByClass("crumbs fl").get(0).getElementsByTag("a").get(0);
            }
            List<WeatherInfoBo> weatherInfoBoList = new ArrayList<>();
            String city_name = a2.text();
//            System.out.println(city_name);
//            String city_name = "gaga";
            Date date = new Date();
            Calendar calendar = new GregorianCalendar();
            calendar.setTime(date);

            int day_index = 0;
            for (Element element : a) {

                calendar.add(calendar.DATE, day_index);
                if (day_index == 0) {
                    day_index++;
                }
                date = calendar.getTime();
                SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
                String dateString = formatter.format(date);

                String quality = "";
                String current = "";
                String today = "";
//                List<String> wind_direction= new ArrayList<>();
                String wind_direction = "";
//
//                //只有当天才有实时温度
//                if (!element.getElementsByClass("op_weather4_twoicon_shishi_title").isEmpty()) {
//                    current = element.getElementsByClass("op_weather4_twoicon_shishi_title").text();
//                }
//                //空气质量
//                if (!element.getElementsByClass("op_weather4_twoicon_aqi_text_today").isEmpty()) {
//                    quality = element.getElementsByClass("op_weather4_twoicon_aqi_text_today").text();
//                }else {
//                    quality = element.getElementsByClass("op_weather4_twoicon_aqi_text").text();
//                }
                //日期
//                if (!element.getElementsByTag("h1").isEmpty()) {
                today = element.getElementsByTag("h1").text();
//                }else {
//                    today = element.getElementsByClass("op_weather4_twoicon_date_day").text();
//                }
                //风向
                wind_direction = element.getElementsByTag("em").html();
                //风
                String wind = element.getElementsByClass("win").text();
                //天气
                String weath = element.getElementsByClass("wea").text();
                //气温
                String temp = element.getElementsByClass("tem").text();

////                System.out.println("天气质量："+quality);
////                System.out.println("实时温度："+current);
//                for(String str:wind_direction){
//                    System.out.println("风向："+str);
//                }
                WeatherInfoBo weatherInfoBo = new WeatherInfoBo(dateString, AreaCode, weath, weather_reptile.temp_dealing(temp), weather_reptile.wind_dirdction_dealing(wind_direction), wind, city_name);
                weatherInfoBoList.add(weatherInfoBo);
                System.out.println("城市编码：" + weatherInfoBo.getArea_code());
                System.out.println("城市：" + weatherInfoBo.getCity_name());
                System.out.println("风向：" + weatherInfoBo.getWind_direction());
                System.out.println("日期：" + weatherInfoBo.getDate());
                System.out.println("风：" + weatherInfoBo.getWind_Power());
                System.out.println("天气：" + weatherInfoBo.getWeather());
                System.out.println("温度：" + weatherInfoBo.getTemperature());
                System.out.println("=============================");
            }
//
//            System.out.println(a.text());
            return weatherInfoBoList;
        } catch (IndexOutOfBoundsException e) {
            e.printStackTrace();
            throw new RuntimeException("读取网页失败，url:"+weatherUrl);
        } catch (IOException i) {
            i.printStackTrace();
            throw new RuntimeException("读取网页超时,:Url:" + weatherUrl);
        }
    }

    public static void main(String[] args) {
        WeatherReptile weatherReptile = new WeatherReptile();
        weatherReptile.getWeather("http://www.weather.com.cn/weather/101010100.shtml", "101010100");
    }

    private String wind_dirdction_dealing(String wind_direction) {
        String reg = "[^\u4e00-\u9fa5]";
        wind_direction = wind_direction.replaceAll(reg, "");
        wind_direction = wind_direction.replace("向", "");
        StringBuffer sb = new StringBuffer(wind_direction);
        sb.insert(wind_direction.indexOf('风') + 1, "/");
        return sb.toString();
    }

    private String temp_dealing(String temp) {
        return temp.replace("/", "~");
    }

}
