package com.skilrock.wls_pos
import com.google.gson.annotations.SerializedName

data class WinClaimedResponse(
    @SerializedName("responseCode")
    val responseCode: Int,
    @SerializedName("responseData")
    val responseData: ResponseData,
    @SerializedName("responseMessage")
    val responseMessage: String
) {
    data class ResponseData(
        @SerializedName("balance")
        val balance: Double,
        @SerializedName("claimAmount")
        val claimAmount: Double,
        @SerializedName("claimTime")
        val claimTime: String,
        @SerializedName("currencySymbol")
        val currencySymbol: String,
        @SerializedName("doneByUserId")
        val doneByUserId: Int,
        @SerializedName("drawClaimedCount")
        val drawClaimedCount: Int,
        @SerializedName("drawData")
        val drawData: List<DrawData>,
        @SerializedName("drawTransMap")
        val drawTransMap: DrawTransMap,
        @SerializedName("gameCode")
        val gameCode: String,
        @SerializedName("gameName")
        val gameName: String,
        @SerializedName("isPwtReprint")
        val isPwtReprint: Boolean,
        @SerializedName("merchantCode")
        val merchantCode: String,
        @SerializedName("merchantTxnId")
        val merchantTxnId: Int,
        @SerializedName("orgName")
        val orgName: String,
        @SerializedName("panelData")
        val panelData: List<PanelData>,
        @SerializedName("playerPurchaseAmount")
        val playerPurchaseAmount: Double,
        @SerializedName("prizeAmount")
        val prizeAmount: String,
        @SerializedName("purchaseTime")
        val purchaseTime: String,
        @SerializedName("reprintCountPwt")
        val reprintCountPwt: String,
        @SerializedName("retailerName")
        val retailerName: String,
        @SerializedName("status")
        val status: String,
        @SerializedName("success")
        val success: Boolean,
        @SerializedName("ticketNumber")
        val ticketNumber: String,
        @SerializedName("totalPay")
        val totalPay: String,
        @SerializedName("totalPurchaseAmount")
        val totalPurchaseAmount: Double,
        @SerializedName("ticketExpiry")
        val ticketExpiry: String,
        @SerializedName("validationCode")
        val validationCode: String,
        @SerializedName("secureJackpotAmount")
        val secureJackpotAmount: Double,
        @SerializedName("doubleJackpotAmount")
        val doubleJackpotAmount: Double,
    ) {
        data class DrawData(
            @SerializedName("drawDate")
            val drawDate: String,
            @SerializedName("drawId")
            val drawId: Int,
            @SerializedName("drawName")
            val drawName: String,
            @SerializedName("drawTime")
            val drawTime: String,
            @SerializedName("isPwtCurrent")
            val isPwtCurrent: Boolean,
            @SerializedName("panelWinList")
            val panelWinList: List<PanelWin>,
            @SerializedName("winCode")
            val winCode: Int,
            @SerializedName("winStatus")
            val winStatus: String,
            @SerializedName("winningAmount")
            val winningAmount: String
        ) {
            data class PanelWin(
                @SerializedName("panelId")
                val panelId: Int,
                @SerializedName("playType")
                val playType: String,
                @SerializedName("status")
                val status: String,
                @SerializedName("valid")
                val valid: Boolean,
                @SerializedName("winningAmt")
                val winningAmt: Double,
                @SerializedName("winningItem")
                val winningItem: Any
            )
        }

        class DrawTransMap

        data class PanelData(
            @SerializedName("betAmountMultiple")
            val betAmountMultiple: Int,
            @SerializedName("betDisplayName")
            val betDisplayName: String,
            @SerializedName("betType")
            val betType: String,
            @SerializedName("numberOfLines")
            val numberOfLines: Int,
            @SerializedName("panelPrice")
            val panelPrice: Double,
            @SerializedName("pickConfig")
            val pickConfig: String,
            @SerializedName("pickDisplayName")
            val pickDisplayName: String,
            @SerializedName("pickType")
            val pickType: String,
            @SerializedName("pickedValues")
            val pickedValues: String,
            @SerializedName("playerPanelPrice")
            val playerPanelPrice: Double,
            @SerializedName("qpPreGenerated")
            val qpPreGenerated: Boolean,
            @SerializedName("quickPick")
            val quickPick: Boolean,
            @SerializedName("tpticketList")
            val tpticketList: Any,
            @SerializedName("unitCost")
            val unitCost: Double,
            @SerializedName("winningMultiplier")
            val winningMultiplier: Any,
            @SerializedName("doubleJackpot")
            val doubleJackpot: Boolean,
            @SerializedName("secureJackpot")
            val secureJackpot: Boolean
        )
    }
}