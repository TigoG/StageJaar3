package health.sensible.sen_gs_1_ca_connector_plugin.delegates

import android.util.Log
import health.sensible.sen_gs_1_ca_connector_plugin.constants.MethodName
import health.sensible.sen_gs_1_ca_connector_plugin.controllers.CloudConnectionController
import health.sensible.sen_gs_1_ca_connector_plugin.controllers.DataStoreController
import health.sensible.sen_gs_1_ca_connector_plugin.generated.type.ConsentEntityType
import health.sensible.sen_gs_1_ca_connector_plugin.models.dataStore.DataPoint
import health.sensible.sen_gs_1_ca_connector_plugin.models.dataStore.GraphQlModel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class DataStoreDelegate(
    private val cloudConnectionController: CloudConnectionController,
    private val dataStoreController: DataStoreController
) : CallDelegate() {
    private val _tag: String = this::class.simpleName.toString()

    override val supportedMethods: List<String>
        get() = listOf(
            MethodName.ADD_DATA_POINT.methodName,
            MethodName.GET_MEASUREMENT_SESSION.methodName,
            MethodName.LIST_MEASUREMENT_SESSIONS.methodName
        )

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            MethodName.ADD_DATA_POINT.methodName -> addDataPoint(call, result)
            MethodName.GET_MEASUREMENT_SESSION.methodName -> getMeasurementSession(call, result)
            MethodName.LIST_MEASUREMENT_SESSIONS.methodName -> listMeasurementSessions(call, result)
            MethodName.LIST_INBOUND_CONSENT.methodName -> {
                CoroutineScope(Dispatchers.Main).launch {
                    listInboundConsent(call, result)
                }
            }
            MethodName.LIST_OUTBOUND_CONSENT.methodName -> {
                CoroutineScope(Dispatchers.Main).launch {
                    listOutboundConsent(call, result)
                }
            }
        }
    }

    /// Add a data point manually
    private fun addDataPoint(call: MethodCall, result: Result) {
        if (!call.hasArgument("point")) {
            result.error("ArgumentError", "Please provide a dataPoint", null)
            return
        }
        val point = GraphQlModel.fromJson<DataPoint>(call.argument("point")!!)
        dataStoreController.saveDataPoint(point)
        result.success(null)
    }

    private fun getMeasurementSession(call: MethodCall, result: Result) {
        if (!call.hasArgument("sessionId")) {
            result.error("ArgumentError", "Please provide a sessionId", null)
            return
        }
        Log.d(_tag, "getMeasurementSession, arguments: ${call.arguments}")

        val sessionId = call.argument<String>("sessionId")!!
        dataStoreController.getLocalCgmSession(sessionId, result)
    }

    private fun listMeasurementSessions(call: MethodCall, result: Result) {
        val includeArchived =
            if (!call.hasArgument("includeArchived")) call.argument<Boolean>("includeArchived")!! else false
        val amountToGet =
            if (!call.hasArgument("namedChunkAmountToGet")) call.argument<Int>("namedChunkAmountToGet")!! else 0
        val offset =
            if (!call.hasArgument("namedChunkOffset")) call.argument<Int>("namedChunkOffset")!! else 0

        cloudConnectionController.listSessions(result, includeArchived, amountToGet, offset)
    }

    private suspend fun listInboundConsent(call: MethodCall, result: Result) {
        val includeInvalid =
            if (!call.hasArgument("includeInvalid")) call.argument<Boolean>("includeInvalid")!! else false

        cloudConnectionController.listInboundConsent(result, includeInvalid)
    }

    private suspend fun listOutboundConsent(call: MethodCall, result: Result) {
        if (!call.hasArgument("entityType")) {
            result.error("ArgumentError", "Please provide a entityType", null)
            return
        }
        val includeInvalid =
            if (!call.hasArgument("includeInvalid")) call.argument<Boolean>("includeInvalid")!! else false

        cloudConnectionController.listOutboundConsent(
            result,
            ConsentEntityType.valueOf(call.argument<String>("entityType")!!),
            includeInvalid
        )
    }
}
