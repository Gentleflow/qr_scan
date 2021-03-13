package tech.gentleflow.qr_scan.factorys;

import android.content.Context;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import tech.gentleflow.qr_scan.views.QrReaderView;

public class QrReaderFactory extends PlatformViewFactory {

    private FlutterPlugin.FlutterPluginBinding flutterPluginBinding;

    public QrReaderFactory(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        super(StandardMessageCodec.INSTANCE);
        this.flutterPluginBinding = flutterPluginBinding;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        return new QrReaderView(context, flutterPluginBinding, id, params);
    }
}
