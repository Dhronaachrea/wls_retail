package com.skilrock.wls_pos


import com.google.gson.annotations.SerializedName

class PanelData : ArrayList<PanelData.PanelDataItem>(){
    data class PanelDataItem(
        @SerializedName("amount")
        val amount: Double,
        @SerializedName("betAmountMultiple")
        val betAmountMultiple: Int,
        @SerializedName("betCode")
        val betCode: String,
        @SerializedName("betName")
        val betName: String,
        @SerializedName("colorCode")
        val colorCode: Any,
        @SerializedName("gameName")
        val gameName: String,
        @SerializedName("isMainBet")
        val isMainBet: Boolean,
        @SerializedName("isQpPreGenerated")
        val isQpPreGenerated: Boolean,
        @SerializedName("isQuickPick")
        val isQuickPick: Boolean,
        @SerializedName("numberOfDraws")
        val numberOfDraws: Int,
        @SerializedName("numberOfLines")
        val numberOfLines: Int,
        @SerializedName("pickCode")
        val pickCode: String,
        @SerializedName("PickConfig")
        val pickConfig: String,
        @SerializedName("pickConfig")
        val twoDPickConfig: String,
        @SerializedName("pickName")
        val pickName: String,
        @SerializedName("pickedValue")
        val pickedValue: String,
        @SerializedName("pickedValues")
        val pickedValues: String,
        @SerializedName("selectBetAmount")
        val selectBetAmount: Int,
        @SerializedName("sideBetHeader")
        val sideBetHeader: Any,
        @SerializedName("totalNumber")
        val totalNumber: Any,
        @SerializedName("unitPrice")
        val unitPrice: Double,
        @SerializedName("winMode")
        val winMode: String,
        @SerializedName("panelPrice")
        val panelPrice: Double,
        @SerializedName("betDisplayName")
        val betDisplayName: String,
        @SerializedName("pickDisplayName")
        val pickDisplayName: String,
        @SerializedName("unitCost")
        val twoDUnitPrice: Double,
        @SerializedName("quickPick")
        val twoDQuickPick: Boolean,
    )
}