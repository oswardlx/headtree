package landing.weather.util;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.stereotype.Service;

@Service("RespFormat")
public class RespFormat {
    public JSONObject FailReturn(String message){
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("success","false");
            jsonObject.put("result",new JSONArray().put(new JSONObject()));
            jsonObject.put("info",message);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject;
    }
}
