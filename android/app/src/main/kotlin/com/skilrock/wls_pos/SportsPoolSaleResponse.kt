package com.skilrock.wls_pos


import com.google.gson.annotations.SerializedName

data class SportsPoolSaleResponse(
   @SerializedName("responseCode") val responseCode: Int?,
   @SerializedName("responseData") val responseData: ResponseData,
   @SerializedName("responseMessage") val responseMessage: String?
) {
   data class ResponseData(
      @SerializedName("addOnDrawData") val addOnDrawData: AddOnDrawData?,
      @SerializedName("addOnDrawId") val addOnDrawId: Int?,
      @SerializedName("addOnDrawNo") val addOnDrawNo: Int?,
      @SerializedName("drawDateTime") val drawDateTime: String,
      @SerializedName("drawFreezeDateTime") val drawFreezeDateTime: String?,
      @SerializedName("drawId") val drawId: Int?,
      @SerializedName("drawNo") val drawNo: Int,
      @SerializedName("gameCode") val gameCode: String?,
      @SerializedName("itemId") val itemId: String?,
      @SerializedName("mainDrawData") val mainDrawData: MainDrawData,
      @SerializedName("message") val message: String?,
      @SerializedName("noOfTicketsPerBoard") val noOfTicketsPerBoard: Int?,
      @SerializedName("orderId") val orderId: String?,
      @SerializedName("playerId") val playerId: Int?,
      @SerializedName("rgRespJson") val rgRespJson: String?,
      @SerializedName("saleStartDateTime") val saleStartDateTime: String?,
      @SerializedName("saleStatus") val saleStatus: String?,
      @SerializedName("ticketNumber") val ticketNumber: String,
      @SerializedName("totalSaleAmount") val totalSaleAmount: Double,
      @SerializedName("transactionDateTime") val transactionDateTime: String?,
      @SerializedName("transactionStatus") val transactionStatus: String?
   ) {
      data class AddOnDrawData(
         @SerializedName("boardCount") val boardCount: Int?,
         @SerializedName("boardUnitPrice") val boardUnitPrice: Double?,
         @SerializedName("boards") val boards: List<Board>,
         @SerializedName("totalPrice") val totalPrice: Double?
      ) {
         data class Board(
            @SerializedName("events") val events: List<Event>,
            @SerializedName("marketCode") val marketCode: String,
            @SerializedName("marketId") val marketId: Int?,
            @SerializedName("marketName") val marketName: String
         ) {
            data class Event(
               @SerializedName("AwayTeamName") val awayTeamName: String,
               @SerializedName("eventId") val eventId: Int,
               @SerializedName("eventName") val eventName: String,
               @SerializedName("homeTeamName") val homeTeamName: String,
               @SerializedName("options") val options: List<Option>,
               @SerializedName("homeTeamAbbr") val homeTeamAbbr: String?,
               @SerializedName("awayTeamAbbr") val awayTeamAbbr: String?,

            ) {
               data class Option(
                  @SerializedName("code") val code: String,
                  @SerializedName("displayName") val displayName: Any,
                  @SerializedName("id") val id: Int,
                  @SerializedName("name") val name: String
               )
            }
         }
      }

      data class MainDrawData(
         @SerializedName("boardCount") val boardCount: Int?,
         @SerializedName("boardUnitPrice") val boardUnitPrice: Double?,
         @SerializedName("boards") val boards: List<Board>,
         @SerializedName("totalPrice") val totalPrice: Double?
      ) {
         data class Board(
            @SerializedName("events") val events: List<Event>,
            @SerializedName("marketCode") val marketCode: String,
            @SerializedName("marketId") val marketId: Int?,
            @SerializedName("marketName") val marketName: String
         ) {
            data class Event(
               @SerializedName("AwayTeamName") val awayTeamName: String,
               @SerializedName("eventId") val eventId: Int,
               @SerializedName("eventName") val eventName: String,
               @SerializedName("homeTeamName") val homeTeamName: String,
               @SerializedName("options") val options: List<Option>,
               @SerializedName("homeTeamAbbr") val homeTeamAbbr: String?,
               @SerializedName("awayTeamAbbr") val awayTeamAbbr: String?,
            ) {
               data class Option(
                  @SerializedName("code") val code: String,
                  @SerializedName("displayName") val displayName: Any,
                  @SerializedName("id") val id: Int,
                  @SerializedName("name") val name: String
               )
            }
         }
      }
   }
}