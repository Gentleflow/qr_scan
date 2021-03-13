package tech.gentleflow.qr_scan;
import android.annotation.SuppressLint;
import android.os.AsyncTask;
import androidx.annotation.NonNull;
import java.io.File;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import tech.gentleflow.qr_scan.factorys.QrReaderFactory;

/** QrScanPlugin */
public class QrScanPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static final String CHANNEL_NAME = "tech.gentleflow.qr_scan";
  private static final String CHANNEL_VIEW_NAME = "tech.gentleflow.qr_scan.reader_view";


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory(CHANNEL_VIEW_NAME,new QrReaderFactory(flutterPluginBinding));
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("imgQrCode")) {
      imgQrCode(call, result);
    } else {
      result.notImplemented();
    }
  }

  @SuppressLint("StaticFieldLeak")
  void imgQrCode(MethodCall call, final Result result) {
    final String filePath = call.argument("file");
    if (filePath == null) {
      result.error("Not found data", null, null);
      return;
    }
    File file = new File(filePath);
    if (!file.exists()) {
      result.error("File not found", null, null);
    }

    new AsyncTask<String, Integer, String>() {
      @Override
      protected String doInBackground(String... params) {
        // 解析二维码/条码
        return QRCodeDecoder.syncDecodeQRCode(filePath);
      }
      @Override
      protected void onPostExecute(String s) {
        super.onPostExecute(s);
        if(null == s){
          result.error("not data", null, null);
        }else {
          result.success(s);
        }
      }
    }.execute(filePath);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
