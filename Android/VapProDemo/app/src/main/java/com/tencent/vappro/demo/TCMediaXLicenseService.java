package com.tencent.vappro.demo;

import android.util.Log;

import com.tencent.tcmediax.api.ILicenseCallback;
import com.tencent.tcmediax.api.TCMediaXBase;

/**
 * TCMediaX License 鉴权服务。
 *
 * 使用 License方式一次性离线完成校验，无需联网。
 *
 * 注意：
 *  - 当前 Demo 内置的 License 绑定的包名为 "com.tencent.tcmediax.demo"，
 *    请确保 app/build.gradle 中的 applicationId 与之一致，否则鉴权将失败。
 *  - 使用你自己项目时，请替换 sLicenseV2 为自己的 License，并同步修改 applicationId。
 */
public class TCMediaXLicenseService {
    private static final String TAG = "TCMediaXLicenseService";

    private TCMediaXLicenseService() {
    }

    private static class Holder {
        private static final TCMediaXLicenseService instance = new TCMediaXLicenseService();
    }

    public static TCMediaXLicenseService getInstance() {
        return Holder.instance;
    }

    //  License 字符串，申请地址：https://tceffect-license.tmf.qq.com/
    private static final String sLicenseV2 =
            "eyJzaWduYXR1cmUiOiJndWZjZGk2SGlIYzd5bVJ3NTE3THBMNzFPcXJUeUNEbGxjTmV3WFVJQldqMEtPQ1VzcVQ1SDVqbHhxWnNzOFhJL1R1SDd6d2pncjhEQzZlQ3BuTm9lZlZ5ZW8zdThCYUZMMjZ0NjZualVBZ3h2eFMxdFhSY002WFkrM29xT3VCdFl0cEt5ZlFVUnBKNm5hQ1FOTGRjOEVRRHRqYnBKZnFRUVNiWnY2dmlBK3ZQMmV0NHdoQUJ3MmdVLythSWR2dmxxT3krUXorcHo1aVFaTzhmKzhBdHEzTTNHR3FXRE9uZmgxMHphQWxHL2V1Y0ZKdi9STmozM1gza2pROW9IVkF3eU05bnJoTXlYYkQ4TlZMMnkxSUZvcmNUclh5dE9ISXpDbC9CVUt0aW9kY2xIOEF0RWhMQmtYdGpoZDQ5YSswN0MyUVV5SDEzekpEemNFQjhUa3BlL2c9PSIsImNvbnRlbnQiOiJRMFV6TXpZelFVWTVSVUl5UkRsRlFXbGdyeHlneUZPVDh2L1BQZStMeUNPakxRTW8rVTdRczB1WWtWMHJLeVlmNWlLMXZ4amhXUlZIMWZiVEVjZDUyTER0LzlHWlh6Qng2RHBUWmM4MzNIS2tRZFlhQllQUU1OY2IvVTBIYzNMWTV5dnhabi9STXdkNzA4M0w1MU50aFY5d2I0d3o3MERlV215WlRoOURnLytkMnlLVVdWOFJJbjFhQnk0ZXB0T21Wc0NVelRqeVdCTHVwQXVuWXVYOXJJVjlTUnBMc29WOFFNTkVGbUpVY3E0U05WczJDNU10dnh5QkhuaW1nMDBaRnozcGdoNXdGRGZoV3MwUThRamE1QT09In0=";

    private final ILicenseCallback mLicenseCallback = new ILicenseCallback() {
        @Override
        public void onResult(int errCode, String msg) {
            Log.d(TAG, "TCMediaX license result: errCode: " + errCode + ", msg: " + msg);
        }
    };

    public void init() {
        TCMediaXBase.getInstance().setLogEnable(DemoApplication.getAppContext(), true);
        //使用本地  License 一次性离线完成校验
        TCMediaXBase.getInstance().setLicense(DemoApplication.getAppContext(), sLicenseV2, mLicenseCallback);
    }
}
