package com.skilrock.wls_pos

import InvFlowResponseData
import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.RemoteException
import android.util.Log
import android.widget.Toast
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.common.apiutil.CommonException
import com.common.apiutil.TimeoutException
import com.common.apiutil.printer.FontErrorException
import com.common.apiutil.printer.GateOpenException
import com.common.apiutil.printer.LowPowerException
import com.common.apiutil.printer.NoPaperException
import com.common.apiutil.printer.OverHeatException
import com.common.apiutil.printer.PaperCutException
import com.common.apiutil.printer.ThermalPrinter.stop
import com.common.apiutil.printer.UsbThermalPrinter
import com.google.gson.Gson
import com.pos.sdk.DeviceManager
import com.pos.sdk.DevicesFactory
import com.pos.sdk.callback.ResultCallback
import com.pos.sdk.printer.PrinterDevice
import com.sunmi.peripheral.printer.InnerPrinterCallback
import com.sunmi.peripheral.printer.InnerPrinterException
import com.sunmi.peripheral.printer.InnerPrinterManager
import com.sunmi.peripheral.printer.InnerResultCallback
import com.sunmi.peripheral.printer.SunmiPrinterService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale


class MainActivity : FlutterActivity() {
    private val mChannel = "com.skilrock.wls_pos/test"
    private lateinit var channel_print: MethodChannel
    private val mChannelForPrint = "com.skilrock.longalottoretail/notification_print"
    private val mChannelForAppAfterWithdrawal =
        "com.skilrock.longalottoretail/channel_afterWithdrawal"

    private val boldFontEnable = byteArrayOf(0x1B, 0x45, 0x1)
    private val boldFontDisable = byteArrayOf(0x1B, 0x45, 0x0)
    private lateinit var channel: MethodChannel
    private lateinit var channel_afterWithdrawal: MethodChannel
    private var mSunmiPrinterService: SunmiPrinterService? = null
    private var mPrinter: PrinterDevice? = null


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // window.addFlags(LayoutParams.FLAG_SECURE) to secure screen from screenshot/screen recording in overall app
        // getWindow().setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE); to secure screen from screenshot/screen recording in overall app
        super.configureFlutterEngine(flutterEngine)
        initializeSunmiPrinter()
        initializeCentermPrinter()

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mChannel)

        channel.setMethodCallHandler { call, result ->
            val argument = call.arguments as Map<*, *>

            if (call.method == "invFlowPrint") {
                val invFlowResponse = argument["invFlowResponse"]
                val startDate = argument["startDate"]
                val endDate = argument["endDate"]
                val userName = argument["name"]
                val showGameWiseOpeningBalanceData: Boolean =
                    argument["showGameWiseOpeningBalanceData"].toString().toBoolean()
                val showGameWiseClosingBalanceData: Boolean =
                    argument["showGameWiseClosingBalanceData"].toString().toBoolean()
                val showReceivedData: Boolean = argument["showReceivedData"].toString().toBoolean()
                val showReturnedData: Boolean = argument["showReturnedData"].toString().toBoolean()
                val showSoldData: Boolean = argument["showSoldData"].toString().toBoolean()
                val bookTicketLength = 8
                val optionTextLength = ("Closing Balance ".length) - 5;
                println("showGameWiseOpeningBalanceData: $showGameWiseOpeningBalanceData")
                println("showGameWiseOpeningBalanceData:type: ${showGameWiseOpeningBalanceData::class.java}")

                val invFlowResponseData =
                    Gson().fromJson(invFlowResponse.toString(), InvFlowResponseData::class.java)
                mSunmiPrinterService?.run {
                    enterPrinterBuffer(true)
                    setAlignment(1, null)
                    sendRAWData(boldFontEnable, null)
                    setFontSize(25f, null)
                    printText("Inventory Flow Report", null)
                    setFontSize(21f, null)
                    printText("\nDate $startDate To $endDate", null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n____________________________\n", null)
                    printText("Organization name : $userName", null)
                    printText("\n____________________________\n", null)

                    sendRAWData(boldFontEnable, null)
                    printColumnsString(
                        arrayOf<String>(
                            "", "Books ", "Tickets"
                        ),
                        intArrayOf(
                            optionTextLength, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 1, 2),
                        null
                    )
                    sendRAWData(boldFontDisable, null)

                    printColumnsString(
                        arrayOf<String>(
                            "OpenBalance ",
                            "${invFlowResponseData.booksOpeningBalance} ",
                            "${invFlowResponseData.ticketsOpeningBalance}"
                        ),
                        intArrayOf(
                            optionTextLength, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 1, 2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            "Received ",
                            "${invFlowResponseData.receivedBooks} ",
                            "${invFlowResponseData.receivedTickets}"
                        ),
                        intArrayOf(
                            optionTextLength, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 1, 2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            "Returned ",
                            "${invFlowResponseData.returnedBooks} ",
                            "${invFlowResponseData.returnedTickets}"
                        ),
                        intArrayOf(
                            optionTextLength, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 1, 2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            "Sales ",
                            "${invFlowResponseData.soldBooks} ",
                            "${invFlowResponseData.soldTickets}"
                        ),
                        intArrayOf(
                            optionTextLength, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 1, 2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            "Closing Balance ",
                            "${invFlowResponseData.booksClosingBalance} ",
                            "${invFlowResponseData.ticketsClosingBalance}"
                        ),
                        intArrayOf(
                            optionTextLength, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 1, 2),
                        null
                    )

                    printText("\n", null)

                    if (showGameWiseOpeningBalanceData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Open Balance ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                optionTextLength, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 1, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)

                        for (gameWiseOpeningData in invFlowResponseData.gameWiseOpeningBalanceData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseOpeningData.gameName + " ",
                                    "${gameWiseOpeningData.totalBooks} ",
                                    "${gameWiseOpeningData.totalTickets}"
                                ),
                                intArrayOf(
                                    optionTextLength, //gameWiseOpeningData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 1, 2),
                                null
                            )
                        }
                    }
                    printText("\n", null)

                    if (showReceivedData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Received ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                optionTextLength, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 1, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)
                        for (gameWiseData in invFlowResponseData.gameWiseData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseData.gameName + " ",
                                    "${gameWiseData.receivedBooks} ",
                                    "${gameWiseData.receivedTickets}"
                                ),
                                intArrayOf(
                                    optionTextLength,//gameWiseData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 1, 2),
                                null
                            )
                        }
                    }
                    printText("\n", null)

                    if (showReturnedData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Returned ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                optionTextLength, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 1, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)
                        for (gameWiseData in invFlowResponseData.gameWiseData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseData.gameName + " ",
                                    "${gameWiseData.returnedBooks} ",
                                    "${gameWiseData.returnedTickets}"
                                ),
                                intArrayOf(
                                    optionTextLength,//gameWiseData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 1, 2),
                                null
                            )
                        }
                    }
                    printText("\n", null)

                    if (showSoldData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Sale ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                optionTextLength, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 1, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)
                        for (gameWiseData in invFlowResponseData.gameWiseData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseData.gameName + " ",
                                    "${gameWiseData.soldBooks} ",
                                    "${gameWiseData.soldTickets}"
                                ),
                                intArrayOf(
                                    optionTextLength,//gameWiseData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 1, 2),
                                null
                            )
                        }
                    }
                    printText("\n", null)

                    if (showGameWiseClosingBalanceData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Closing Balance ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                optionTextLength, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 1, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)

                        for (gameWiseClosingData in invFlowResponseData.gameWiseClosingBalanceData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseClosingData.gameName + " ",
                                    "${gameWiseClosingData.totalBooks} ",
                                    "${gameWiseClosingData.totalTickets}"
                                ),
                                intArrayOf(
                                    optionTextLength,//gameWiseClosingData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 1, 2),
                                null
                            )
                        }
                    }
                    printText("\n------ FOR DEMO ------\n\n", null)
                    exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                        override fun onRunResult(isSuccess: Boolean) {}

                        override fun onReturnString(result: String?) {}

                        override fun onRaiseException(code: Int, msg: String?) {
                            activity.runOnUiThread {
                                Toast.makeText(
                                    activity,
                                    "Something went wrong while printing, Please try again",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                            result.error("-1", msg, "Something went wrong while printing")
                        }

                        override fun onPrintResult(code: Int, msg: String?) {
                            if (updatePrinterState() != 1) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")

                            } else {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)
                            }
                        }
                    })

                } ?: this.let {
                    val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                    if (getDeviceName() == "QUALCOMM M1") {
                        usbThermalPrinter.run {
                            try {
                                reset()
                                start(1)
                                setTextSize(25)
                                addString("")
                                setBold(true)
                                setGray(1)
                                setAlgin(1)
                                addString("Inventory Flow Report")
                                setTextSize(21)
                                setBold(false)
                                addString("Date $startDate To $endDate")
                                setBold(false)
                                addString(printLineStringData(getPaperLength()))
                                addString("Organization name : $userName")
                                addString(printLineStringData(getPaperLength()))
                                addString("\n")
                                setBold(true)
                                addString(printThreeStringData("        ", "Books", "Tickets"))
                                setBold(false)
                                setAlgin(0)
                                addString(
                                    printThreeStringData(
                                        "OpenBalance",
                                        "${invFlowResponseData.booksOpeningBalance}",
                                        "${invFlowResponseData.ticketsOpeningBalance}"
                                    )
                                )
                                addString(
                                    printThreeStringData(
                                        "Received",
                                        "${invFlowResponseData.receivedBooks}",
                                        "${invFlowResponseData.receivedTickets}"
                                    )
                                )
                                addString(
                                    printThreeStringData(
                                        "Returned",
                                        "${invFlowResponseData.returnedBooks}",
                                        "${invFlowResponseData.returnedTickets}"
                                    )
                                )
                                addString(
                                    printThreeStringData(
                                        "Sales",
                                        "${invFlowResponseData.soldBooks}",
                                        "${invFlowResponseData.soldTickets}"
                                    )
                                )
                                addString(
                                    printThreeStringData(
                                        "Closing Balance",
                                        "${invFlowResponseData.booksClosingBalance}",
                                        "${invFlowResponseData.ticketsClosingBalance}"
                                    )
                                )
                                setAlgin(0)
                                if (showGameWiseOpeningBalanceData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(
                                        printThreeStringData(
                                            "Open Balance ",
                                            "Books ",
                                            "Tickets"
                                        )
                                    )
                                    setBold(false)
                                    for (gameWiseOpeningData in invFlowResponseData.gameWiseOpeningBalanceData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseOpeningData.gameName,
                                                "${gameWiseOpeningData.totalBooks}",
                                                "${gameWiseOpeningData.totalTickets}"
                                            )
                                        )
                                    }
                                }
                                if (showReceivedData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(
                                        printThreeStringData(
                                            "Received ",
                                            "Books ",
                                            "Tickets"
                                        )
                                    )
                                    setBold(false)
                                    for (gameWiseData in invFlowResponseData.gameWiseData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseData.gameName,
                                                "${gameWiseData.receivedBooks} ",
                                                "${gameWiseData.receivedTickets}"
                                            )
                                        )
                                    }
                                }
                                if (showReturnedData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(
                                        printThreeStringData(
                                            "Returned ",
                                            "Books ",
                                            "Tickets"
                                        )
                                    )
                                    setBold(false)
                                    for (gameWiseData in invFlowResponseData.gameWiseData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseData.gameName,
                                                "${gameWiseData.returnedBooks} ",
                                                "${gameWiseData.returnedTickets}"
                                            )
                                        )
                                    }
                                }
                                if (showSoldData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(printThreeStringData("Sale ", "Books ", "Tickets"))
                                    setBold(false)
                                    for (gameWiseData in invFlowResponseData.gameWiseData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseData.gameName,
                                                "${gameWiseData.soldBooks} ",
                                                "${gameWiseData.soldTickets}"
                                            )
                                        )
                                    }
                                }
                                if (showGameWiseClosingBalanceData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(
                                        printThreeStringData(
                                            "Closing Balance ",
                                            "Books ",
                                            "Tickets"
                                        )
                                    )
                                    setBold(false)
                                    for (gameWiseClosingData in invFlowResponseData.gameWiseClosingBalanceData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseClosingData.gameName,
                                                "${gameWiseClosingData.totalBooks} ",
                                                "${gameWiseClosingData.totalTickets}"
                                            )
                                        )
                                    }
                                }
                                setAlgin(1)
                                addString("\n")
                                addString("----- FOR DEMO -----")
                                addString("\n")
                                printString()
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)
                            } catch (e: java.lang.Exception) {
                                showMsgAccordingToException(e as CommonException, result)
                                stop()
                                e.printStackTrace()
                            }
                        }

                    } else {
                        android.util.Log.d("TAg", "configureFlutterEngine: -----------")
                        result.error(
                            "-1",
                            "Unable to find printer",
                            "no sunmi or no usb thermal printer"
                        )
                    }
                }
            }
            //sports pool print
            else if (call.method == "sports_buy") {
                val currencyCode = argument["currencyCode"]
                val username = argument["username"]
                val saleResponse = argument["saleResponse"]
                val isReprint = argument["reprint"] ?: false
                val saleResponseData =
                    Gson().fromJson(saleResponse.toString(), SportsPoolSaleResponse::class.java)
                val qrCodeHelperObject = QRBarcodeHelper(activity.baseContext)
                qrCodeHelperObject.setContent(saleResponseData.responseData.ticketNumber)
                val bitmap =
                    BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)

                mSunmiPrinterService?.run {
                    enterPrinterBuffer(true)
                    setAlignment(1, null)
                    printBitmapCustom(resizedBitmap, 1, null)
                    sendRAWData(boldFontEnable, null)
                    setFontSize(24f, null)
                    printText("\n\n${saleResponseData.responseData.gameCode}", null)
                    sendRAWData(boldFontDisable, null)
                    if (saleResponseData.responseData.transactionDateTime != null) {
                        printText("\nPurchase Time", null)
                        val purchaseDate: String =
                            saleResponseData.responseData.transactionDateTime.split(" ")[0]
                        val purchaseTime: String =
                            saleResponseData.responseData.transactionDateTime.split(" ")[1]
                        printText(
                            "\n${getFormattedDateForWinClaim(purchaseDate)} ${
                                getFormattedTime(
                                    purchaseTime
                                )
                            }", null
                        )
                        printText("\n____________________________", null)
                    }
                    printText("\nTicket Number", null)
                    printText("\n${saleResponseData.responseData.ticketNumber}", null)
                    printText("\n____________________________\n", null)
                    printColumnsString(
                        arrayOf<String>(
                            "Draw Time",
                            "Draw No.",
                        ),
                        intArrayOf(
                            "Draw Time".length, "Draw No.".length
                        ),
                        intArrayOf(0, 2),
                        null
                    )
                    var drawDate = saleResponseData.responseData.drawDateTime.split(" ")[0]
                    var drawTime = saleResponseData.responseData.drawDateTime.split(" ")[1]
                    printColumnsString(
                        arrayOf<String>(
                            "${getFormattedDateForWinClaim(drawDate)} ${
                                getFormattedTime(
                                    drawTime
                                )
                            }",
                            "${saleResponseData.responseData.drawNo}",
                        ),
                        intArrayOf(
                            "${getFormattedDateForWinClaim(drawDate)} ${
                                getFormattedTime(
                                    drawTime
                                )
                            }".length, "${saleResponseData.responseData.drawNo}".length
                        ),
                        intArrayOf(0, 2),
                        null
                    )
                    sendRAWData(boldFontEnable, null)
                    setFontSize(24f, null)
                    printText("\n\nDraw Result", null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n\nResult Will be declared on", null)
                    printText(
                        "\n${getFormattedDateForWinClaim(drawDate)} ${
                            getFormattedTime(
                                drawTime
                            )
                        }\n\n", null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            "Your Total Bet",
                            "$currencyCode ",
                            "${saleResponseData.responseData.totalSaleAmount}",
                        ),
                        intArrayOf(
                            "Your Total Bet".length,
                            "$currencyCode ".length,
                            "${saleResponseData.responseData.totalSaleAmount}".length
                        ),
                        intArrayOf(0, 2, 2),
                        null
                    )
                    printText("\n____________________________", null)
                    //setFontSize(20f, null)
                    printText("\n\nBet Details\n", null)
                    for (i in 0 until saleResponseData.responseData.mainDrawData.boards.size) {
                        printText(
                            "\nMarket/Bet On : ${saleResponseData.responseData.mainDrawData.boards[i].marketName}\n\n",
                            null
                        )
                        for (j in 0 until saleResponseData.responseData.mainDrawData.boards[i].events.size) {
                            printColumnsString(
                                arrayOf<String>(
                                    if (!saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr}" else
                                        saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName,
                                    getSelectedOptions(saleResponseData.responseData.mainDrawData.boards[i].events[j].options)
                                ),
                                intArrayOf(
                                    (if (!saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr}" else
                                        saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName).length,
                                    getSelectedOptions(saleResponseData.responseData.mainDrawData.boards[i].events[j].options).length
                                ),
                                intArrayOf(0, 2),
                                null
                            )
                            printText("\n____________________________\n", null)
                        }
                        printText("\n****************************\n", null)
                    }
                    if (saleResponseData.responseData.addOnDrawData != null && saleResponseData.responseData.addOnDrawData.boards != null) {
                        for (i in 0 until saleResponseData.responseData.addOnDrawData.boards.size) {
                            printText(
                                "\nMarket/Bet On : ${saleResponseData.responseData.addOnDrawData.boards[i].marketName}\n\n",
                                null
                            )
                            for (j in 0 until saleResponseData.responseData.addOnDrawData.boards[i].events.size) {
                                printColumnsString(
                                    arrayOf<String>(
                                        if (!saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr}" else
                                            saleResponseData.responseData.addOnDrawData.boards[i].events[j].eventName,
                                        getSelectedOptionsAddOn(saleResponseData.responseData.addOnDrawData.boards[i].events[j].options)
                                    ),
                                    intArrayOf(
                                        (if (!saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr}" else
                                            saleResponseData.responseData.addOnDrawData.boards[i].events[j].eventName).length,
                                        getSelectedOptionsAddOn(saleResponseData.responseData.addOnDrawData.boards[i].events[j].options).length
                                    ),
                                    intArrayOf(0, 2),
                                    null
                                )
                                printText("\n____________________________\n", null)
                            }
                            printText("\n****************************\n", null)
                        }
                    }
                    printText("\n", null)
                    printBitmapCustom(qrCodeHelperObject.qrcOde, 1, null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n${saleResponseData.responseData.ticketNumber}", null)
                    printText("\n\n$username", null)
                    // setFontSize(24f, null)
                    if (isReprint == true) {
                        printText("\nReprint Ticket", null)
                    }
                    printText("\n------ FOR DEMO ------\n\n\n", null)
                    exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                        override fun onRunResult(isSuccess: Boolean) {}

                        override fun onReturnString(result: String?) {}

                        override fun onRaiseException(code: Int, msg: String?) {
                            activity.runOnUiThread {
                                Toast.makeText(
                                    activity,
                                    "Something went wrong while printing, Please try again",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                            result.error("-1", msg, "Something went wrong while printing")
                        }

                        override fun onPrintResult(code: Int, msg: String?) {
                            if (updatePrinterState() != 1) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")

                            } else {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)
                            }
                        }
                    })
                } ?: this.let {
                    val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                    if (getDeviceName() == "QUALCOMM M1") {
                        usbThermalPrinter.run {
                            try {
                                reset()
                                start(1)
                                setTextSize(28)
                                addString("")
                                setBold(true)
                                setGray(1)
                                setAlgin(1)
                                printLogo(resizedBitmap, true)
                                addString(saleResponseData.responseData.gameCode)
                                setTextSize(22)
                                if (saleResponseData.responseData.transactionDateTime != null) {
                                    val purchaseDate: String =
                                        saleResponseData.responseData.transactionDateTime.split(" ")[0]
                                    val purchaseTime: String =
                                        saleResponseData.responseData.transactionDateTime.split(" ")[1]
                                    setItalic(true)
                                    setBold(false)
                                    addString("Purchase Time")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(
                                        "${getFormattedDateForWinClaim(purchaseDate)} ${
                                            getFormattedTime(
                                                purchaseTime
                                            )
                                        }"
                                    )
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                }
                                addString("Ticket Number")
                                setItalic(false)
                                setBold(true)
                                setTextSize(24)
                                addString(saleResponseData.responseData.ticketNumber)
                                setItalic(false)
                                addString(printLineStringData(getPaperLength()))
                                setBold(true)
                                setTextSize(24)
                                addString(
                                    printTwoStringStringData(
                                        "Draw Time",
                                        "Draw No."
                                    )
                                )
                                setBold(false)
                                var drawDate =
                                    saleResponseData.responseData.drawDateTime.split(" ")[0]
                                var drawTime =
                                    saleResponseData.responseData.drawDateTime.split(" ")[1]
                                addString(
                                    printTwoStringStringData(
                                        "${getFormattedDateForWinClaim(drawDate)} ${
                                            getFormattedTime(
                                                drawTime
                                            )
                                        }",
                                        "${saleResponseData.responseData.drawNo}",
                                    )
                                )
                                addString(printLineStringData(getPaperLength()))
                                setTextSize(22)
                                addString("Draw Result")
                                addString("Result will be declared on")
                                //var drawDate = saleResponseData.responseData.drawDateTime.split(" ")[0]
                                //var drawTime = saleResponseData.responseData.drawDateTim*/e.split(" ")[1]
                                addString(
                                    "${getFormattedDateForWinClaim(drawDate)} ${
                                        getFormattedTime(
                                            drawTime
                                        )
                                    }"
                                )
                                setTextSize(24)
                                addString(
                                    printTwoStringStringData(
                                        "Your Total Bet",
                                        "$currencyCode ${saleResponseData.responseData.totalSaleAmount}",
                                    )
                                )
                                addString(printLineStringData(getPaperLength()))
                                setAlgin(1)
                                addString("Bet Details")
                                //setTextSize(20)
                                Log.d("TAg", "saleResponseData.responseData.mainDrawData started")
                                for (i in 0 until saleResponseData.responseData.mainDrawData.boards.size) {
                                    setAlgin(1)
                                    addString("\nMarket/Bet On : ${saleResponseData.responseData.mainDrawData.boards[i].marketName}\n")
                                    for (j in 0 until saleResponseData.responseData.mainDrawData.boards[i].events.size) {
                                        addString(
                                            printTwoStringStringData(
                                                if (!saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr}" else saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName,
                                                getSelectedOptions(saleResponseData.responseData.mainDrawData.boards[i].events[j].options),
                                            )
                                        )
                                        addString(printLineStringData(getPaperLength()))
                                    }
                                    addString(printLineStarData(getPaperLength()))
                                }
                                //   Log.d("TAg", "saleResponseData.responseData.addOnDrawData: ${saleResponseData.responseData.addOnDrawData}")
                                if (saleResponseData.responseData.addOnDrawData != null && saleResponseData.responseData.addOnDrawData.boards != null) {
                                    for (i in 0 until saleResponseData.responseData.addOnDrawData.boards.size) {
                                        addString("\nMarket/Bet On : ${saleResponseData.responseData.addOnDrawData.boards[i].marketName}\n")
                                        for (j in 0 until saleResponseData.responseData.addOnDrawData.boards[i].events.size) {
                                            addString(
                                                printTwoStringStringData(
                                                    if (!saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr}" else saleResponseData.responseData.addOnDrawData.boards[i].events[j].eventName,
                                                    getSelectedOptionsAddOn(saleResponseData.responseData.addOnDrawData.boards[i].events[j].options),
                                                )
                                            )
                                            addString(printLineStringData(getPaperLength()))
                                        }
                                        addString(printLineStarData(getPaperLength()))
                                    }
                                }
                                addString("\n")
                                printLogo(qrCodeHelperObject.qrcOde, true)
                                addString(saleResponseData.responseData.ticketNumber)
                                addString("\n")
                                addString("$username")
                                addString("\n")
                                if (isReprint == true) {
                                    addString("Reprint Ticket")
                                }
                                addString("----- FOR DEMO -----")
                                addString("\n")
                                addString("\n")
                                addString("\n")
                                printString()
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)

                            } catch (e: java.lang.Exception) {
                                showMsgAccordingToException(e as CommonException, result)
                                stop()
                                e.printStackTrace()
                            }
                        }

                    } else {
                        result.error(
                            "-1",
                            "Unable to find printer",
                            "no sunmi or no usb thermal printer"
                        )
                    }
                }
            }
            if (call.method == "spWinClaim") {
                val currencyCode = argument["currencyCode"]
                val username = argument["username"]
                val saleResponse = argument["saleResponse"]
                val statusMessage = argument["statusMessage"]
                val winningStatus = argument["winningStatus"]
                val winningAmount = argument["winningAmount"]

                val saleResponseData =
                    Gson().fromJson(saleResponse.toString(), SportsPoolSaleResponse::class.java)
                val qrCodeHelperObject = QRBarcodeHelper(activity.baseContext)
                qrCodeHelperObject.setContent(saleResponseData.responseData.ticketNumber)
                val bitmap =
                    BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)

                mSunmiPrinterService?.run {
                    enterPrinterBuffer(true)
                    setAlignment(1, null)
                    printBitmapCustom(resizedBitmap, 1, null)
                    sendRAWData(boldFontEnable, null)
                    setFontSize(24f, null)
                    printText("\n\n${saleResponseData.responseData.gameCode}", null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n${saleResponseData.responseData.ticketNumber}\n", null)
                    printColumnsString(
                        arrayOf<String>(
                            "Draw Time",
                            "Draw No.",
                        ),
                        intArrayOf(
                            "Draw Time".length, "Draw No.".length
                        ),
                        intArrayOf(0, 2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            saleResponseData.responseData.drawDateTime,
                            "${saleResponseData.responseData.drawNo}",
                        ),
                        intArrayOf(
                            saleResponseData.responseData.drawDateTime.length,
                            "${saleResponseData.responseData.drawNo}".length
                        ),
                        intArrayOf(0, 2),
                        null
                    )
                    sendRAWData(boldFontEnable, null)
                    setFontSize(24f, null)
                    printText("\n\nDraw Result", null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n\n$statusMessage", null)
                    printText("\n\nWinning Status: $winningStatus", null)
                    printText("\nWinning Amount: $winningAmount\n\n", null)
                    printColumnsString(
                        arrayOf<String>(
                            "Your Total Bet",
                            "$currencyCode ",
                            "${saleResponseData.responseData.totalSaleAmount}",
                        ),
                        intArrayOf(
                            "Your Total Bet".length,
                            "$currencyCode ".length,
                            "${saleResponseData.responseData.totalSaleAmount}".length
                        ),
                        intArrayOf(0, 2, 2),
                        null
                    )
                    //setFontSize(20f, null)
                    for (i in 0 until saleResponseData.responseData.mainDrawData.boards.size) {
                        printText(
                            "\n${saleResponseData.responseData.mainDrawData.boards[i].marketName}\n",
                            null
                        )
                        for (j in 0 until saleResponseData.responseData.mainDrawData.boards[i].events.size) {
                            printColumnsString(
                                arrayOf<String>(
                                    if (!saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr}" else
                                        saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName,
                                    getSelectedOptions(saleResponseData.responseData.mainDrawData.boards[i].events[j].options)
                                ),
                                intArrayOf(
                                    (if (!saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr}" else
                                        saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName).length,
                                    getSelectedOptions(saleResponseData.responseData.mainDrawData.boards[i].events[j].options).length
                                ),
                                intArrayOf(0, 2),
                                null
                            )
                        }
                        printText("\n____________________________\n", null)
                    }
                    if (saleResponseData.responseData.addOnDrawData != null && saleResponseData.responseData.addOnDrawData.boards != null) {
                        for (i in 0 until saleResponseData.responseData.addOnDrawData.boards.size) {
                            printText(
                                "\n${saleResponseData.responseData.addOnDrawData.boards[i].marketName}\n",
                                null
                            )
                            for (j in 0 until saleResponseData.responseData.addOnDrawData.boards[i].events.size) {
                                printColumnsString(
                                    arrayOf<String>(
                                        if (!saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr}" else
                                            saleResponseData.responseData.addOnDrawData.boards[i].events[j].eventName,
                                        getSelectedOptionsAddOn(saleResponseData.responseData.addOnDrawData.boards[i].events[j].options)
                                    ),
                                    intArrayOf(
                                        (if (!saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr}" else
                                            saleResponseData.responseData.addOnDrawData.boards[i].events[j].eventName).length,
                                        getSelectedOptionsAddOn(saleResponseData.responseData.addOnDrawData.boards[i].events[j].options).length
                                    ),
                                    intArrayOf(0, 2),
                                    null
                                )
                            }
                            printText("\n____________________________\n", null)
                        }
                    }
                    printText("\n", null)
                    printBitmapCustom(qrCodeHelperObject.qrcOde, 1, null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n${saleResponseData.responseData.ticketNumber}", null)
                    printText("\n\n$username", null)
                    // setFontSize(24f, null)
                    printText("\n------ FOR DEMO ------\n\n\n", null)
                    exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                        override fun onRunResult(isSuccess: Boolean) {}

                        override fun onReturnString(result: String?) {}

                        override fun onRaiseException(code: Int, msg: String?) {
                            activity.runOnUiThread {
                                Toast.makeText(
                                    activity,
                                    "Something went wrong while printing, Please try again",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                            result.error("-1", msg, "Something went wrong while printing")
                        }

                        override fun onPrintResult(code: Int, msg: String?) {
                            if (updatePrinterState() != 1) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")

                            } else {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)
                            }
                        }
                    })
                } ?: this.let {
                    val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                    if (getDeviceName() == "QUALCOMM M1") {
                        usbThermalPrinter.run {
                            try {
                                reset()
                                start(1)
                                setTextSize(28)
                                addString("")
                                setBold(true)
                                setGray(1)
                                setAlgin(1)
                                printLogo(resizedBitmap, true)
                                addString(saleResponseData.responseData.gameCode)
                                setTextSize(22)
                                setItalic(true)
                                setBold(false)
                                addString(saleResponseData.responseData.ticketNumber)
                                setItalic(false)
                                setBold(true)
                                setTextSize(24)
                                addString(
                                    printTwoStringStringData(
                                        "Draw Time",
                                        "Draw No."
                                    )
                                )
                                setBold(false)
                                addString(
                                    printTwoStringStringData(
                                        saleResponseData.responseData.drawDateTime,
                                        "${saleResponseData.responseData.drawNo}",
                                    )
                                )
                                //addString(printLineStringData(getPaperLength()))
                                setTextSize(22)
                                addString("Draw Result")
                                addString("\n\n$statusMessage\"")
                                addString("\n\nWinning Status: $winningStatus\"")
                                addString("\n\nwinningAmount: $winningAmount\"")
                                setTextSize(24)
                                addString(
                                    printTwoStringStringData(
                                        "Your Total Bet",
                                        "$currencyCode ${saleResponseData.responseData.totalSaleAmount}",
                                    )
                                )
                                //setTextSize(20)
                                Log.d("TAg", "saleResponseData.responseData.mainDrawData started")
                                for (i in 0 until saleResponseData.responseData.mainDrawData.boards.size) {
                                    setAlgin(1)
                                    addString("\n${saleResponseData.responseData.mainDrawData.boards[i].marketName}\n")
                                    for (j in 0 until saleResponseData.responseData.mainDrawData.boards[i].events.size) {
                                        addString(
                                            printTwoStringStringData(
                                                if (!saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.mainDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.mainDrawData.boards[i].events[j].awayTeamAbbr}" else saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName,
                                                getSelectedOptions(saleResponseData.responseData.mainDrawData.boards[i].events[j].options),
                                            )
                                        )
                                    }
                                    addString(printLineStringData(getPaperLength()))
                                }
                                //   Log.d("TAg", "saleResponseData.responseData.addOnDrawData: ${saleResponseData.responseData.addOnDrawData}")
                                if (saleResponseData.responseData.addOnDrawData != null && saleResponseData.responseData.addOnDrawData.boards != null) {
                                    for (i in 0 until saleResponseData.responseData.addOnDrawData.boards.size) {
                                        addString("\n${saleResponseData.responseData.addOnDrawData.boards[i].marketName}\n")
                                        for (j in 0 until saleResponseData.responseData.addOnDrawData.boards[i].events.size) {
                                            addString(
                                                printTwoStringStringData(
                                                    if (!saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr.isNullOrEmpty() && !saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr.isNullOrEmpty()) "${saleResponseData.responseData.addOnDrawData.boards[i].events[j].homeTeamAbbr} VS ${saleResponseData.responseData.addOnDrawData.boards[i].events[j].awayTeamAbbr}" else saleResponseData.responseData.addOnDrawData.boards[i].events[j].eventName,
                                                    getSelectedOptionsAddOn(saleResponseData.responseData.addOnDrawData.boards[i].events[j].options),
                                                )
                                            )
                                        }
                                        addString(printLineStringData(getPaperLength()))
                                    }
                                }
                                addString("\n")
                                printLogo(qrCodeHelperObject.qrcOde, true)
                                addString(saleResponseData.responseData.ticketNumber)
                                addString("\n")
                                addString("$username")
                                addString("\n")
                                addString("----- FOR DEMO -----")
                                addString("\n")
                                addString("\n")
                                addString("\n")
                                printString()
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)

                            } catch (e: java.lang.Exception) {
                                showMsgAccordingToException(e as CommonException, result)
                                stop()
                                e.printStackTrace()
                            }
                        }

                    } else {
                        result.error(
                            "-1",
                            "Unable to find printer",
                            "no sunmi or no usb thermal printer"
                        )
                    }
                }
            }

            // else part
            else {
                val currencyCode = argument["currencyCode"]
                val username = argument["username"]
                val saleResponse = argument["saleResponse"]
                val panelArgData = argument["panelData"]
                val cancelTicketResponse = argument["cancelTicketResponse"]
                val rePrintResponse = argument["rePrint"]
                val resultDataResponse = argument["resultData"]
                val winClaimedResponse = argument["winClaimedResponse"]
                val lastWinningSaleTicketNo = argument["lastWinningSaleTicketNo"]


                //Data for Balance/Invoice Report

                val orgName = argument["orgName"]
                val orgId = argument["orgId"]
                val balanceInvoiceToAndFromDate = argument["toAndFromDate"]
                val balanceInvoiceData = argument["balanceInvoiceData"]
                val reportHeaderName = argument["reportHeaderName"]
                val operationalCashReportData = argument["operationCashReportData"]

                val balanceInvoiceResponseReport = Gson().fromJson(
                    balanceInvoiceData.toString(),
                    BalanceInvoiceReportResponse::class.java
                )
                val operationalCashReport = Gson().fromJson(
                    operationalCashReportData.toString(), OperationalCashReportResponse::class.java
                )

                val saleResponseData =
                    Gson().fromJson(saleResponse.toString(), SaleResponseData::class.java)
                val panelData = Gson().fromJson(panelArgData.toString(), PanelData::class.java)
                android.util.Log.d("chandra", "configureFlutterEngine: 2d myanmar: $panelData")
                android.util.Log.d(
                    "chandra",
                    "configureFlutterEngine: 2d myanmar:sale: $saleResponseData"
                )

                val cancelTicketResponseData = Gson().fromJson(
                    cancelTicketResponse.toString(),
                    CancelTicketResponseData::class.java
                )
                val resultResponseData =
                    Gson().fromJson(resultDataResponse.toString(), ResultData::class.java)
                val winClaimedResponseData =
                    Gson().fromJson(winClaimedResponse.toString(), WinClaimedResponse::class.java)
                Log.d(
                    "Rajneesh",
                    "configureFlutterEngine -- : winClaimedResponse ---------: ${winClaimedResponse.toString()}"
                )
                if (call.method == "buy") {
                    Log.d("chandra", "buy ---------")

                    val qrCodeHelperObject = QRBarcodeHelper(activity.baseContext)
                    qrCodeHelperObject.setContent(saleResponseData.responseData.ticketNumber)
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)
                    val imageSize = 50
                    val jackpotDoubleEnablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_double_enable
                        )
                    val jackpotDoubleEnableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotDoubleEnablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    val jackpotDoubleDisablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_double_disable
                        )
                    val jackpotDoubleDisableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotDoubleDisablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    val jackpotSecureEnablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_secure_enable
                        )
                    val jackpotSecureEnableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotSecureEnablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    val jackpotSecureDisablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_secure_disable
                        )
                    val jackpotSecureDisableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotSecureDisablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    mSunmiPrinterService?.run {

                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${saleResponseData.responseData.gameName}", null)
                        sendRAWData(boldFontDisable, null)
                        printText("\nPurchase Time", null)
                        val purchaseDate: String =
                            saleResponseData.responseData.purchaseTime.split(" ")[0]
                        val purchaseTime: String =
                            saleResponseData.responseData.purchaseTime.split(" ")[1]
                        printText(
                            "\n${getFormattedDate(purchaseDate)} ${
                                getFormattedTime(
                                    purchaseTime
                                )
                            }", null
                        )
                        printText("\nTicket Number", null)
                        printText("\n${saleResponseData.responseData.ticketNumber}", null)
                        printText("\n____________________________", null)
                        printText("\nDraw Timing", null)
                        for (i in saleResponseData.responseData.drawData) {
                            printText("\n${getFormattedDate(i.drawDate)} ${i.drawTime}", null)
                        }
                        printText("\n____________________________", null)
                        printText("\nBet Details", null)
                        var amount = 0.0
                        var numberString: String
                        Log.i(
                            "TaG",
                            "---------------->${saleResponseData.responseData.panelData.size}"
                        )
                        if (saleResponseData.responseData.gameCode == "ThaiLottery") {
                            for (i in 0 until saleResponseData.responseData.panelData.size) {
                                if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Number",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText(
                                        "\n${saleResponseData.responseData.panelData[i].pickedValues}\n",
                                        null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            "${saleResponseData.responseData.panelData[i].pickDisplayName} : ${saleResponseData.responseData.panelData[i].betDisplayName}",
                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                        ),
                                        intArrayOf(
                                            "${saleResponseData.responseData.panelData[i].pickDisplayName} : ${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            "No of lines",
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                        ),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                }
                            }
                        } else if (saleResponseData.responseData.gameCode == "TwoDMYANMAAR") {
                            for (i in 0 until saleResponseData.responseData.panelData.size) {
                                val isQp =
                                    if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Number",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText(
                                        "\n${saleResponseData.responseData.panelData[i].pickedValues}\n",
                                        null
                                    )
                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                        printColumnsString(
                                            arrayOf(
                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                "${saleResponseData.responseData.panelData[i].panelPrice} $currencyCode"
                                            ),
                                            intArrayOf(
                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                "${saleResponseData.responseData.panelData[i].panelPrice} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                    } else {
                                        printColumnsString(
                                            arrayOf(
                                                "${saleResponseData.responseData.panelData[i].betDisplayName}/${saleResponseData.responseData.panelData[i].pickDisplayName}",
                                                "${saleResponseData.responseData.panelData[i].panelPrice} $currencyCode"
                                            ),
                                            intArrayOf(
                                                "${saleResponseData.responseData.panelData[i].betDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                                "${saleResponseData.responseData.panelData[i].panelPrice} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                    }
                                    printColumnsString(
                                        arrayOf(
                                            "No of lines",
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                        ),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += saleResponseData.responseData.panelData[i].panelPrice
                                }
                            }
                        } else {
                            for (i in 0 until panelData.size) {
                                val isQp =
                                    if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Number",
                                        ignoreCase = true
                                    )
                                ) {
                                    if (saleResponseData.responseData.panelData[i].pickType.equals(
                                            "Banker",
                                            ignoreCase = true
                                        )
                                    ) {
                                        numberString =
                                            saleResponseData.responseData.panelData[i].pickedValues
                                        val banker: Array<String> =
                                            numberString.split("-").toTypedArray()
                                        printText("\nUL - ${banker[0]}", null)
                                        printText("\nLL - ${banker[1]}\n", null)
                                        if (saleResponseData.responseData.panelData[i].quickPick) {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        } else {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        }
                                        printColumnsString(
                                            arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                            intArrayOf(
                                                "No of lines".length,
                                                "${panelData[i].numberOfLines}".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )

                                        printText("\n----------------------------", null)
                                        amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines

                                    } else {
                                        printText("\n${panelData[i].pickedValue}\n", null)
                                        if (saleResponseData.responseData.gameCode == "DailyLotto") {
                                            val doubleJackpotImage: Bitmap =
                                                if (saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                    jackpotDoubleEnableResizedBitmap
                                                } else {
                                                    jackpotDoubleDisableResizedBitmap
                                                }
                                            val secureJackpotImage: Bitmap =
                                                if (saleResponseData.responseData.panelData[i].secureJackpot) {
                                                    jackpotSecureEnableResizedBitmap
                                                } else {
                                                    jackpotSecureDisableResizedBitmap
                                                }
                                            printBitmapCustom(doubleJackpotImage, 1, null)
                                            printText("\n", null)
                                            printText("${saleResponseData.responseData.doubleJackpotAmount} $currencyCode", null)
                                            printText("\n", null)
                                            printBitmapCustom(secureJackpotImage, 1, null)
                                            printText("\n", null)
                                            printText("${saleResponseData.responseData.secureJackpotAmount} $currencyCode", null)
                                            printText("\n", null)
                                        }
                                        if (saleResponseData.responseData.panelData[i].quickPick) {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        } else {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        }
                                        printColumnsString(
                                            arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                            intArrayOf(
                                                "No of lines".length,
                                                "${panelData[i].numberOfLines}".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                        printText("\n----------------------------", null)
                                        if (saleResponseData.responseData.gameCode == "DailyLotto") {
                                            var panelAmount = 0.0
                                            var doubleJackpotPanelAmount = 0.0
                                            var secureJackpotPanelAmount = 0.0
                                            panelAmount =
                                                saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                            if (saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                doubleJackpotPanelAmount =
                                                    panelAmount * saleResponseData.responseData.doubleJackpotAmount
                                            }
                                            if (saleResponseData.responseData.panelData[i].secureJackpot) {
                                                secureJackpotPanelAmount =
                                                    panelAmount * saleResponseData.responseData.secureJackpotAmount
                                            }
                                            amount += panelAmount + doubleJackpotPanelAmount + secureJackpotPanelAmount;
                                        } else {
                                            amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                        }
                                    }

                                } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Market",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText(
                                        "\n${saleResponseData.responseData.panelData[i].betDisplayName}\n",
                                        null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            saleResponseData.responseData.panelData[i].pickDisplayName,
                                            "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                        ),
                                        intArrayOf(
                                            saleResponseData.responseData.panelData[i].pickDisplayName.length,
                                            "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printColumnsString(
                                        arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Label",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText("\n${panelData[i].pickedValue}\n", null)
                                    printColumnsString(
                                        arrayOf(
                                            "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                            "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                        ),
                                        intArrayOf(
                                            "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                            "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printColumnsString(
                                        arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                }
                            }
                        }
                        printText("\nAmount                  $amount", null)
                        printText(
                            "\nNo of Draws(s)              ${saleResponseData.responseData.drawData.size}",
                            null
                        )
                        sendRAWData(boldFontEnable, null)
                        printText(
                            "\nTOTAL AMOUNT         ${saleResponseData.responseData.totalPurchaseAmount} $currencyCode\n\n",
                            null
                        )
                        printBitmapCustom(qrCodeHelperObject.qrcOde, 1, null)
                        sendRAWData(boldFontDisable, null)
                        printText("\n${saleResponseData.responseData.ticketNumber}", null)
                        printText("\n\n$username", null)
                        printText(
                            "\nTicket Validity: ${saleResponseData.responseData.ticketExpiry}\n",
                            null
                        )
                        printText("\n------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(28)
                                    addString("")
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(saleResponseData.responseData.gameName)
                                    setTextSize(22)
                                    val purchaseDate: String =
                                        saleResponseData.responseData.purchaseTime.split(" ")[0]
                                    val purchaseTime: String =
                                        saleResponseData.responseData.purchaseTime.split(" ")[1]
                                    setItalic(true)
                                    setBold(false)
                                    addString("Purchase Time")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(
                                        "${getFormattedDate(purchaseDate)} ${
                                            getFormattedTime(
                                                purchaseTime
                                            )
                                        }"
                                    )
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Ticket Number")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(saleResponseData.responseData.ticketNumber)
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Draw Timing")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    for (i in saleResponseData.responseData.drawData) {
                                        addString("${getFormattedDate(i.drawDate)} ${i.drawTime}")

                                    }
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Bet Details")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    var amount = 0.0
                                    var numberString: String
                                    if (saleResponseData.responseData.gameCode == "ThaiLottery") {
                                        for (i in 0 until saleResponseData.responseData.panelData.size) {
                                            if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(saleResponseData.responseData.panelData[i].pickedValues)
                                                addString(
                                                    printTwoStringStringData(
                                                        "${saleResponseData.responseData.panelData[i].pickDisplayName} : ${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                        "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    )
                                                )
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != saleResponseData.responseData.panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                            }
                                        }
                                    }
                                    else if (saleResponseData.responseData.gameCode == "TwoDMYANMAAR") {
                                        for (i in 0 until saleResponseData.responseData.panelData.size) {
                                            val isQp =
                                                if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                            if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(saleResponseData.responseData.panelData[i].pickedValues)
                                                if (saleResponseData.responseData.panelData[i].quickPick) {
                                                    addString(
                                                        printTwoStringStringData(
                                                            "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                            " ${saleResponseData.responseData.panelData[i].panelPrice} $currencyCode"
                                                        )
                                                    )
                                                } else {
                                                    addString(
                                                        printTwoStringStringData(
                                                            "${saleResponseData.responseData.panelData[i].betDisplayName}/${saleResponseData.responseData.panelData[i].pickDisplayName}",
                                                            " ${saleResponseData.responseData.panelData[i].panelPrice} $currencyCode"
                                                        )
                                                    )
                                                }
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != saleResponseData.responseData.panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += saleResponseData.responseData.panelData[i].panelPrice
                                            }
                                        }

                                    }
                                    else if (saleResponseData.responseData.gameCode == "powerball"){
                                        for (i in 0 until saleResponseData.responseData.panelData.size) {
                                            val isQp =
                                                if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                            if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                if (saleResponseData.responseData.panelData[i].pickType.equals(
                                                        "Banker",
                                                        ignoreCase = true
                                                    )
                                                ) {
                                                    numberString =
                                                        saleResponseData.responseData.panelData[i].pickedValues
                                                    val banker: Array<String> =
                                                        numberString.split("-").toTypedArray()

                                                    addString("UL - ${banker[0]}")
                                                    addString("LL - ${banker[1]}")
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    addString(printDashStringData(getPaperLength()))
                                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines

                                                } else {
                                                    addString(saleResponseData.responseData.panelData[i].pickedValues)
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )
                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                               "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    if (i != saleResponseData.responseData.panelData.size - 1) addString(
                                                        printDashStringData(getPaperLength())
                                                    )
                                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines

                                                }

                                            } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Market",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(saleResponseData.responseData.panelData[i].betDisplayName)
                                                addString(
                                                    printTwoStringStringData(
                                                        saleResponseData.responseData.panelData[i].pickDisplayName,
                                                        "${saleResponseData.responseData.panelData[i].unitCost *saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    )
                                                )
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != saleResponseData.responseData.panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                            }
                                        }
                                    }
                                    else {
                                        for (i in 0 until panelData.size) {
                                            val isQp =
                                                if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                            if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                if (saleResponseData.responseData.panelData[i].pickType.equals(
                                                        "Banker",
                                                        ignoreCase = true
                                                    )
                                                ) {
                                                    numberString =
                                                        saleResponseData.responseData.panelData[i].pickedValues
                                                    val banker: Array<String> =
                                                        numberString.split("-").toTypedArray()

                                                    addString("UL - ${banker[0]}")
                                                    addString("LL - ${banker[1]}")
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    addString(printDashStringData(getPaperLength()))
                                                    amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines

                                                } else {
                                                    addString(panelData[i].pickedValue)
                                                    if (saleResponseData.responseData.gameCode == "DailyLotto") {
                                                        val doubleJackpotImage: Bitmap =
                                                            if (saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                                jackpotDoubleEnableResizedBitmap
                                                            } else {
                                                                jackpotDoubleDisableResizedBitmap
                                                            }
                                                        val secureJackpotImage: Bitmap =
                                                            if (saleResponseData.responseData.panelData[i].secureJackpot) {
                                                                jackpotSecureEnableResizedBitmap
                                                            } else {
                                                                jackpotSecureDisableResizedBitmap
                                                            }
                                                        printLogo(doubleJackpotImage, true)
                                                        endLine()
                                                        addString("${saleResponseData.responseData.doubleJackpotAmount} $currencyCode")
                                                        endLine()
                                                        printLogo(secureJackpotImage, true)
                                                        endLine()
                                                        addString("${saleResponseData.responseData.secureJackpotAmount} $currencyCode")
                                                    }
                                                    /*if (saleResponseData.responseData.gameCode == "DailyLotto" && saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                        addString("Double The Grand Prize")
                                                    }
                                                    if (saleResponseData.responseData.gameCode == "DailyLotto" && saleResponseData.responseData.panelData[i].secureJackpot) {
                                                        addString("Secure The Grand Prize")
                                                    }*/
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                if (saleResponseData.responseData.gameCode == "TwoDMYANMAAR") "${panelData[i].betName}$isQp" else "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )
                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                if (saleResponseData.responseData.gameCode == "TwoDMYANMAAR") "${panelData[i].betName}/${panelData[i].pickName}" else "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    if (i != panelData.size - 1) addString(
                                                        printDashStringData(getPaperLength())
                                                    )
                                                    if (saleResponseData.responseData.gameCode == "DailyLotto") {
                                                        var panelAmount = 0.0
                                                        var doubleJackpotPanelAmount = 0.0
                                                        var secureJackpotPanelAmount = 0.0
                                                        panelAmount =
                                                            saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                                        if (saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                            doubleJackpotPanelAmount =
                                                                panelAmount * saleResponseData.responseData.doubleJackpotAmount
                                                        }
                                                        if (saleResponseData.responseData.panelData[i].secureJackpot) {
                                                            secureJackpotPanelAmount =
                                                                panelAmount * saleResponseData.responseData.secureJackpotAmount
                                                        }
                                                        amount += panelAmount + doubleJackpotPanelAmount + secureJackpotPanelAmount;
                                                    } else {
                                                        amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                                    }
                                                }

                                            } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Market",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(saleResponseData.responseData.panelData[i].betDisplayName)
                                                addString(
                                                    printTwoStringStringData(
                                                        saleResponseData.responseData.panelData[i].pickDisplayName,
                                                        "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                    )
                                                )
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                            }
                                        }
                                    }
                                    setBold(true)
                                    addString(printLineStringData(getPaperLength()))
                                    setTextSize(24)
                                    addString(printTwoStringStringData("Amount", "$amount"))
                                    addString(
                                        printTwoStringStringData(
                                            "No of Draws(s)",
                                            "${saleResponseData.responseData.drawData.size}"
                                        )
                                    )
                                    addString(printDashStringData(getPaperLength()))
                                    addString(
                                        printTwoStringStringData(
                                            "TOTAL AMOUNT",
                                            "${saleResponseData.responseData.totalPurchaseAmount} $currencyCode"
                                        )
                                    )
                                    addString(" ")
                                    printLogo(qrCodeHelperObject.qrcOde, true)
                                    addString(saleResponseData.responseData.ticketNumber)
                                    addString(" ")
                                    addString("$username")
                                    addString("Ticket Validity: ${saleResponseData.responseData.ticketExpiry}")
                                    addString("\n")
                                    addString("----- FOR DEMO -----")
                                    addString("\n")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)

                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
                else if (call.method == "dgeCancelTicket") {
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)

                    mSunmiPrinterService?.run {

                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)// logo
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${cancelTicketResponseData.responseData.gameName}", null)
                        sendRAWData(boldFontDisable, null)
                        printText("\nTicket Number", null)
                        printText("\n${cancelTicketResponseData.responseData.ticketNo}", null)
                        printText("\n____________________________\n", null)
                        sendRAWData(boldFontEnable, null)
                        printText("Ticket Cancelled\n", null)
                        sendRAWData(boldFontDisable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Refund Amount :",
                                "${cancelTicketResponseData.responseData.refundAmount} ${currencyCode}"
                            ),
                            intArrayOf(
                                "Refund Amount :".length,
                                "${cancelTicketResponseData.responseData.refundAmount} ${currencyCode}".length
                            ),
                            intArrayOf(0, 2),
                            null
                        )
                        printText("\n\n$username", null)
                        printText("\n------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(28)
                                    addString("")
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(cancelTicketResponseData.responseData.gameName)
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Ticket Number")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(cancelTicketResponseData.responseData.ticketNo)
                                    setBold(true)
                                    addString(printLineStringData(getPaperLength()))
                                    setTextSize(24)
                                    addString("Ticket Cancelled")
                                    setBold(false)
                                    addString(
                                        printTwoStringStringData(
                                            "Refund Amount :",
                                            "${cancelTicketResponseData.responseData.refundAmount} ${currencyCode}"
                                        )
                                    )
                                    addString("\n")
                                    addString("----- FOR DEMO -----")
                                    addString("\n")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)

                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
                else if (call.method == "dgeReprint") {
                    Log.d("chandra", "dgeReprint ---------")
                    val qrCodeHelperObject = QRBarcodeHelper(activity.baseContext)
                    qrCodeHelperObject.setContent(saleResponseData.responseData.ticketNumber)
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)
                    val imageSize = 50
                    val jackpotDoubleEnablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_double_enable
                        )
                    val jackpotDoubleEnableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotDoubleEnablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    val jackpotDoubleDisablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_double_disable
                        )
                    val jackpotDoubleDisableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotDoubleDisablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    val jackpotSecureEnablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_secure_enable
                        )
                    val jackpotSecureEnableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotSecureEnablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    val jackpotSecureDisablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_secure_disable
                        )
                    val jackpotSecureDisableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotSecureDisablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    mSunmiPrinterService?.run {

                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${saleResponseData.responseData.gameName}", null)
                        sendRAWData(boldFontDisable, null)
                        printText("\nPurchase Time", null)
                        val purchaseDate: String =
                            saleResponseData.responseData.purchaseTime.split(" ")[0]
                        val purchaseTime: String =
                            saleResponseData.responseData.purchaseTime.split(" ")[1]
                        printText(
                            "\n${getFormattedDate(purchaseDate)} ${
                                getFormattedTime(
                                    purchaseTime
                                )
                            }", null
                        )
                        printText("\nTicket Number", null)
                        printText("\n${saleResponseData.responseData.ticketNumber}", null)
                        printText("\n____________________________", null)
                        printText("\nDraw Timing", null)
                        for (i in saleResponseData.responseData.drawData) {
                            printText("\n${getFormattedDate(i.drawDate)} ${i.drawTime}", null)
                        }
                        printText("\n____________________________", null)
                        printText("\nBet Details", null)
                        var amount = 0.0
                        var numberString: String
                        if (saleResponseData.responseData.gameCode == "TwoDMYANMAAR") {
                            for (i in 0 until panelData.size) {
                                val isQp =
                                    if (panelData[i].twoDQuickPick) "/QP" else " "
                                if (panelData[i].twoDPickConfig.equals(
                                        "Number",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText(
                                        "\n${saleResponseData.responseData.panelData[i].pickedValues}\n",
                                        null
                                    )
                                    if (panelData[i].twoDQuickPick) {
                                        printColumnsString(
                                            arrayOf(
                                                "${panelData[i].betDisplayName}$isQp",
                                                " ${panelData[i].panelPrice} $currencyCode"

                                            ),
                                            intArrayOf(
                                                "${panelData[i].betDisplayName}$isQp".length,
                                                " ${panelData[i].panelPrice} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )

                                    } else {
                                        printColumnsString(
                                            arrayOf(
                                                "${panelData[i].betDisplayName}/${panelData[i].pickDisplayName}",
                                                " ${panelData[i].panelPrice} $currencyCode"
                                            ),
                                            intArrayOf(
                                                "${panelData[i].betDisplayName}/${panelData[i].pickDisplayName}".length,
                                                " ${panelData[i].panelPrice} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )

                                    }
                                    printColumnsString(
                                        arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += panelData[i].panelPrice//panelData[i].twoDUnitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                }
                            }
                        } else {
                            for (i in 0 until panelData.size) {
                                val isQp =
                                    if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Number",
                                        ignoreCase = true
                                    )
                                ) {
                                    if (saleResponseData.responseData.panelData[i].pickType.equals(
                                            "Banker",
                                            ignoreCase = true
                                        )
                                    ) {
                                        numberString =
                                            saleResponseData.responseData.panelData[i].pickedValues
                                        val banker: Array<String> =
                                            numberString.split("-").toTypedArray()
                                        printText("\nUL - ${banker[0]}", null)
                                        printText("\nLL - ${banker[1]}\n", null)
                                        if (saleResponseData.responseData.panelData[i].quickPick) {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                    "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                    "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        } else {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                    "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                                    "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )
                                        }
                                        printColumnsString(
                                            arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                            intArrayOf(
                                                "No of lines".length,
                                                "${panelData[i].numberOfLines}".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )

                                        printText("\n----------------------------", null)
                                        amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines

                                    } else {
                                        printText(
                                            "\n${saleResponseData.responseData.panelData[i].pickedValues}\n",
                                            null
                                        )
                                        if (saleResponseData.responseData.gameCode == "DailyLotto") {
                                            val doubleJackpotImage: Bitmap =
                                                if (saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                    jackpotDoubleEnableResizedBitmap
                                                } else {
                                                    jackpotDoubleDisableResizedBitmap
                                                }
                                            val secureJackpotImage: Bitmap =
                                                if (saleResponseData.responseData.panelData[i].secureJackpot) {
                                                    jackpotSecureEnableResizedBitmap
                                                } else {
                                                    jackpotSecureDisableResizedBitmap
                                                }
                                            printBitmapCustom(doubleJackpotImage, 1, null)
                                            printText("\n", null)
                                            printText("${saleResponseData.responseData.doubleJackpotAmount} $currencyCode", null)
                                            printText("\n", null)
                                            printBitmapCustom(secureJackpotImage, 1, null)
                                            printText("\n", null)
                                            printText("${saleResponseData.responseData.secureJackpotAmount} $currencyCode", null)
                                            printText("\n", null)
                                        }
                                        if (saleResponseData.responseData.panelData[i].quickPick) {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                    "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                    "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        } else {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                    "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                                    "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        }
                                        printColumnsString(
                                            arrayOf(
                                                "No of lines",
                                                "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                            ),
                                            intArrayOf(
                                                "No of lines".length,
                                                "${saleResponseData.responseData.panelData[i].numberOfLines}".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                        printText("\n----------------------------", null)
                                        if (saleResponseData.responseData.gameCode == "DailyLotto") {
                                            var panelAmount = 0.0
                                            var doubleJackpotPanelAmount = 0.0
                                            var secureJackpotPanelAmount = 0.0
                                            panelAmount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                            if (saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                doubleJackpotPanelAmount =
                                                    panelAmount * saleResponseData.responseData.doubleJackpotAmount
                                            }
                                            if (saleResponseData.responseData.panelData[i].secureJackpot) {
                                                secureJackpotPanelAmount =
                                                    panelAmount * saleResponseData.responseData.secureJackpotAmount
                                            }
                                            amount += panelAmount + doubleJackpotPanelAmount + secureJackpotPanelAmount
                                        } else {
                                            amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                        }
                                    }

                                } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Market",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText(
                                        "\n${saleResponseData.responseData.panelData[i].betDisplayName}\n",
                                        null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            saleResponseData.responseData.panelData[i].pickDisplayName,
                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                        ),
                                        intArrayOf(
                                            saleResponseData.responseData.panelData[i].pickDisplayName.length,
                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            "No of lines",
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                        ),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                }
                            }
                        }
                        printText("\nAmount                  $amount", null)
                        printText(
                            "\nNo of Draws(s)              ${saleResponseData.responseData.drawData.size}",
                            null
                        )
                        sendRAWData(boldFontEnable, null)
                        printText(
                            "\nTOTAL AMOUNT         ${saleResponseData.responseData.totalPurchaseAmount} $currencyCode\n\n",
                            null
                        )
                        printBitmapCustom(qrCodeHelperObject.qrcOde, 1, null)
                        sendRAWData(boldFontDisable, null)
                        printText("\n${saleResponseData.responseData.ticketNumber}", null)
                        printText("\n\n$username", null)
                        printText(
                            "\nTicket Validity: ${saleResponseData.responseData.ticketExpiry}\n",
                            null
                        )
                        printText("Reprint Ticket",null)
                        printText("\n------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(28)
                                    addString("")
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(saleResponseData.responseData.gameName)
                                    setTextSize(22)
                                    val purchaseDate: String =
                                        saleResponseData.responseData.purchaseTime.split(" ")[0]
                                    val purchaseTime: String =
                                        saleResponseData.responseData.purchaseTime.split(" ")[1]
                                    setItalic(true)
                                    setBold(false)
                                    addString("Purchase Time")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(
                                        "${getFormattedDate(purchaseDate)} ${
                                            getFormattedTime(
                                                purchaseTime
                                            )
                                        }"
                                    )
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Ticket Number")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(saleResponseData.responseData.ticketNumber)
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Draw Timing")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    for (i in saleResponseData.responseData.drawData) {
                                        addString("${getFormattedDate(i.drawDate)} ${i.drawTime}")

                                    }
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Bet Details")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    var amount = 0.0
                                    var numberString: String
                                    if (saleResponseData.responseData.gameCode == "TwoDMYANMAAR") {
                                        for (i in 0 until panelData.size) {
                                            val isQp =
                                                if (panelData[i].twoDQuickPick) "/QP" else " "
                                            if (panelData[i].twoDPickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(saleResponseData.responseData.panelData[i].pickedValues)
                                                if (panelData[i].twoDQuickPick) {
                                                    addString(
                                                        printTwoStringStringData(
                                                            "${panelData[i].betDisplayName}$isQp",
                                                            " ${panelData[i].panelPrice} $currencyCode"
                                                        )
                                                    )

                                                } else {
                                                    addString(
                                                        printTwoStringStringData(
                                                            "${panelData[i].betDisplayName}/${panelData[i].pickDisplayName}",
                                                            " ${panelData[i].panelPrice} $currencyCode"
                                                        )
                                                    )

                                                }
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += panelData[i].panelPrice
                                            }
                                        }
                                    }
                                    else if (saleResponseData.responseData.gameCode == "powerball"){
                                        for (i in 0 until saleResponseData.responseData.panelData.size) {
                                            val isQp =
                                                if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                            if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                if (saleResponseData.responseData.panelData[i].pickType.equals(
                                                        "Banker",
                                                        ignoreCase = true
                                                    )
                                                ) {
                                                    numberString =
                                                        saleResponseData.responseData.panelData[i].pickedValues
                                                    val banker: Array<String> =
                                                        numberString.split("-").toTypedArray()

                                                    addString("UL - ${banker[0]}")
                                                    addString("LL - ${banker[1]}")
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    addString(printDashStringData(getPaperLength()))
                                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines

                                                } else {
                                                    addString(saleResponseData.responseData.panelData[i].pickedValues)
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )
                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    if (i != saleResponseData.responseData.panelData.size - 1) addString(
                                                        printDashStringData(getPaperLength())
                                                    )
                                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines

                                                }

                                            } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Market",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(saleResponseData.responseData.panelData[i].betDisplayName)
                                                addString(
                                                    printTwoStringStringData(
                                                        saleResponseData.responseData.panelData[i].pickDisplayName,
                                                        "${saleResponseData.responseData.panelData[i].unitCost *saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    )
                                                )
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != saleResponseData.responseData.panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                            }
                                        }
                                    }
                                    else {
                                        for (i in 0 until panelData.size) {
                                            val isQp =
                                                if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                            if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                if (saleResponseData.responseData.panelData[i].pickType.equals(
                                                        "Banker",
                                                        ignoreCase = true
                                                    )
                                                ) {
                                                    numberString =
                                                        saleResponseData.responseData.panelData[i].pickedValues
                                                    val banker: Array<String> =
                                                        numberString.split("-").toTypedArray()

                                                    addString("UL - ${banker[0]}")
                                                    addString("LL - ${banker[1]}")
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    addString(printDashStringData(getPaperLength()))
                                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines

                                                } else {
                                                    addString(saleResponseData.responseData.panelData[i].pickedValues)
                                                    if (saleResponseData.responseData.gameCode == "DailyLotto") {
                                                        val doubleJackpotImage: Bitmap =
                                                            if (saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                                jackpotDoubleEnableResizedBitmap
                                                            } else {
                                                                jackpotDoubleDisableResizedBitmap
                                                            }
                                                        val secureJackpotImage: Bitmap =
                                                            if (saleResponseData.responseData.panelData[i].secureJackpot) {
                                                                jackpotSecureEnableResizedBitmap
                                                            } else {
                                                                jackpotSecureDisableResizedBitmap
                                                            }
                                                        printLogo(doubleJackpotImage, true)
                                                        endLine()
                                                        addString("${saleResponseData.responseData.doubleJackpotAmount} $currencyCode")
                                                        endLine()
                                                        printLogo(secureJackpotImage, true)
                                                        endLine()
                                                        addString("${saleResponseData.responseData.secureJackpotAmount} $currencyCode")
                                                    }
                                                   /* if (saleResponseData.responseData.gameCode == "DailyLotto" && saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                        addString("Double The Grand Prize")
                                                    }
                                                    if (saleResponseData.responseData.gameCode == "DailyLotto" && saleResponseData.responseData.panelData[i].secureJackpot) {
                                                        addString("Secure The Grand Prize")
                                                    }*/
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    if (i != panelData.size - 1) addString(
                                                        printDashStringData(getPaperLength())
                                                    )
                                                    if (saleResponseData.responseData.gameCode == "DailyLotto") {
                                                        var panelAmount = 0.0
                                                        var doubleJackpotPanelAmount = 0.0
                                                        var secureJackpotPanelAmount = 0.0
                                                        panelAmount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                                        if (saleResponseData.responseData.panelData[i].doubleJackpot) {
                                                            doubleJackpotPanelAmount =
                                                                panelAmount * saleResponseData.responseData.doubleJackpotAmount
                                                        }
                                                        if (saleResponseData.responseData.panelData[i].secureJackpot) {
                                                            secureJackpotPanelAmount =
                                                                panelAmount * saleResponseData.responseData.secureJackpotAmount
                                                        }
                                                        amount += panelAmount + doubleJackpotPanelAmount + secureJackpotPanelAmount
                                                    } else {
                                                        amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                                    }
                                                }

                                            } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Market",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(saleResponseData.responseData.panelData[i].betDisplayName)
                                                addString(
                                                    printTwoStringStringData(
                                                        saleResponseData.responseData.panelData[i].pickDisplayName,
                                                        "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    )
                                                )
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                            }
                                        }
                                    }
                                    setBold(true)
                                    addString(printLineStringData(getPaperLength()))
                                    setTextSize(24)
                                    addString(printTwoStringStringData("Amount", "$amount"))
                                    addString(
                                        printTwoStringStringData(
                                            "No of Draws(s)",
                                            "${saleResponseData.responseData.drawData.size}"
                                        )
                                    )
                                    addString(printDashStringData(getPaperLength()))
                                    addString(
                                        printTwoStringStringData(
                                            "TOTAL AMOUNT",
                                            "${saleResponseData.responseData.totalPurchaseAmount} $currencyCode"
                                        )
                                    )
                                    addString(" ")
                                    printLogo(qrCodeHelperObject.qrcOde, true)
                                    addString(saleResponseData.responseData.ticketNumber)
                                    addString(" ")
                                    addString("$username")
                                    addString("Ticket Validity: ${saleResponseData.responseData.ticketExpiry}")
                                    addString("Reprint Ticket")
                                    addString("\n")
                                    addString("----- FOR DEMO -----")
                                    addString("\n")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)

                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
                else if (call.method == "dgeLastResult") {
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)
                    Log.i("TaG", "resultResponseData------->${resultResponseData}")
                    mSunmiPrinterService?.run {

                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${resultResponseData.drawName}", null)
                        sendRAWData(boldFontDisable, null)
                        printText("\nDraw Time", null)
                        /*val purchaseDate: String = resultResponseData.drawTime.split(" ")[0]
                        val purchaseTime: String = resultResponseData.drawTime.split(" ")[1]*/
                        printText("\n${resultResponseData.drawTime}", null)
                        printText("\n____________________________", null)
                        printText("\nResult", null)
                        printText("\n${resultResponseData.winningNo}", null)
                        printText("\n____________________________", null)
                        if (resultResponseData?.sideBetMatchInfo != null && resultResponseData.sideBetMatchInfo.isNotEmpty()) {
                            printText("\nSide Bet\n", null)
                            var amount = 0.0
                            var numberString: String
                            for (i in 0 until resultResponseData.sideBetMatchInfo.size) {
                                printColumnsString(
                                    arrayOf<String>(
                                        "${resultResponseData.sideBetMatchInfo[i]?.betDisplayName}",
                                        "${resultResponseData.sideBetMatchInfo[i]?.pickTypeName}"
                                    ),
                                    intArrayOf(
                                        "${resultResponseData.sideBetMatchInfo[i]?.betDisplayName}".length,
                                        "${resultResponseData.sideBetMatchInfo[i]?.pickTypeName}".length
                                    ),
                                    intArrayOf(0, 2),
                                    null
                                )
                                printText("\n____________________________\n", null)
                            }
                        }

                        sendRAWData(boldFontEnable, null)

                        if (resultResponseData.winningMultiplierInfo != null) {
                            printColumnsString(
                                arrayOf<String>(
                                    "Winning Multiplier",
                                    "${resultResponseData.winningMultiplierInfo.multiplierCode} (${resultResponseData.winningMultiplierInfo?.value})"
                                ),
                                intArrayOf(
                                    "Winning Multiplier".length,
                                    "${resultResponseData.winningMultiplierInfo.multiplierCode} (${resultResponseData.winningMultiplierInfo?.value})".length
                                ),
                                intArrayOf(0, 2),
                                null
                            )
                        }

                        sendRAWData(boldFontDisable, null)
                        printText("\n------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        if (getDeviceName() == "QUALCOMM M1") {
                            val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(28)
                                    addString("")
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(resultResponseData.drawName)
                                    setTextSize(22)
                                    addString(printDashStringData(getPaperLength()))
                                    addString("Draw Time")
                                    addString(resultResponseData.drawTime)
                                    addString(printDashStringData(getPaperLength()))
                                    addString("Result")
                                    addString("${resultResponseData.winningNo}")
                                    addString(printDashStringData(getPaperLength()))
                                    if (resultResponseData?.sideBetMatchInfo != null && resultResponseData.sideBetMatchInfo.isNotEmpty()) {
                                        addString("Side Bet")
                                        var amount = 0.0
                                        var numberString: String
                                        for (i in 0 until resultResponseData.sideBetMatchInfo.size) {
                                            addString(
                                                printTwoStringStringData(
                                                    "${resultResponseData.sideBetMatchInfo[i]?.betDisplayName}",
                                                    "${resultResponseData.sideBetMatchInfo[i]?.pickTypeName}"
                                                )
                                            )
                                            addString(printDashStringData(getPaperLength()))
                                        }
                                    }

                                    /*val purchaseDate: String = resultResponseData.drawTime.split(" ")[0]
                                    val purchaseTime: String = resultResponseData.drawTime.split(" ")[1]*/
                                    addString(printDashStringData(getPaperLength()))
                                    resultResponseData.winningMultiplierInfo?.let {
                                        addString(
                                            printTwoStringStringData(
                                                "Winning Multiplier",
                                                "${resultResponseData.winningMultiplierInfo.multiplierCode} (${resultResponseData.winningMultiplierInfo.value})"
                                            )
                                        )
                                        addString(printDashStringData(getPaperLength()))
                                        addString("\n")
                                    }
                                    addString("\n")
                                    addString("----- FOR DEMO -----")
                                    addString("\n")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }

                    }
                }
                else if (call.method == "winClaim") {
                    val qrCodeHelperObject = QRBarcodeHelper(activity.baseContext)
                    qrCodeHelperObject.setContent(winClaimedResponseData.responseData.ticketNumber)
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)
                    var isReprint = false;
                    val imageSize = 50
                    val jackpotDoubleEnablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_double_enable
                        )
                    val jackpotDoubleEnableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotDoubleEnablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    val jackpotDoubleDisablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_double_disable
                        )
                    val jackpotDoubleDisableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotDoubleDisablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    val jackpotSecureEnablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_secure_enable
                        )
                    val jackpotSecureEnableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotSecureEnablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    val jackpotSecureDisablebitmap =
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.jackpot_secure_disable
                        )
                    val jackpotSecureDisableResizedBitmap = Bitmap.createScaledBitmap(
                        jackpotSecureDisablebitmap,
                        imageSize,
                        imageSize,
                        false
                    )

                    mSunmiPrinterService?.run {
                        Log.i(
                            "TAg",
                            "-------winClaimedResponseData.responseData.panelData.size--------->${winClaimedResponseData.responseData.panelData.size}"
                        )
                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${winClaimedResponseData.responseData.gameName}", null)
                        printText("\n____________________________\n\n", null)
                        sendRAWData(boldFontDisable, null)
                        for (i in winClaimedResponseData.responseData.drawData) {
                            printColumnsString(
                                arrayOf("Draw Date", getFormattedDateForWinClaim(i.drawDate)),
                                intArrayOf(
                                    "Draw Date".length,
                                    getFormattedDateForWinClaim(i.drawDate).length
                                ),
                                intArrayOf(0, 2), null
                            )
                            printColumnsString(
                                arrayOf("Draw Time", i.drawTime),
                                intArrayOf("Draw Time".length, i.drawTime.length),
                                intArrayOf(0, 2), null
                            )
                            printColumnsString(
                                arrayOf("Win Status", i.winStatus),
                                intArrayOf("Win Status".length, i.winStatus.length),
                                intArrayOf(0, 2), null
                            )
                            printColumnsString(
                                arrayOf("Winning Amount", "${i.winningAmount} ${currencyCode}"),
                                intArrayOf(
                                    "Winning Amount".length,
                                    "${i.winningAmount} ${currencyCode}".length
                                ),
                                intArrayOf(0, 2), null
                            )
                            printText("____________________________\n\n", null)
                        }
                        sendRAWData(boldFontEnable, null)
                        printText("Reprint Ticket\n__________________\n", null)
                        sendRAWData(boldFontDisable, null)
                        var amount = 0.0
                        var numberString: String
                        if (winClaimedResponseData.responseData.gameCode == "ThaiLottery") {
                            for (i in 0 until winClaimedResponseData.responseData.panelData.size) {
                                if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Number",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText(
                                        "\n${winClaimedResponseData.responseData.panelData[i].pickedValues}\n",
                                        null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            "${winClaimedResponseData.responseData.panelData[i].pickDisplayName} : ${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                            "${winClaimedResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                        ),
                                        intArrayOf(
                                            "${winClaimedResponseData.responseData.panelData[i].pickDisplayName} : ${winClaimedResponseData.responseData.panelData[i].betDisplayName}".length,
                                            "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            "No of lines",
                                            "${winClaimedResponseData.responseData.panelData[i].numberOfLines}"
                                        ),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${winClaimedResponseData.responseData.panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines
                                }
                            }
                        } else {
                            val panelDataList = winClaimedResponseData.responseData.panelData;
                            panelDataList.let { mPanelData ->
                                for (i in 0 until mPanelData.size) {
                                    val isQp =
                                        if (winClaimedResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                    if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                            "Number",
                                            ignoreCase = true
                                        )
                                    ) {
                                        if (winClaimedResponseData.responseData.panelData[i].pickType.equals(
                                                "Banker",
                                                ignoreCase = true
                                            )
                                        ) {
                                            numberString =
                                                winClaimedResponseData.responseData.panelData[i].pickedValues
                                            val banker: Array<String> =
                                                numberString.split("-").toTypedArray()
                                            printText("\nUL - ${banker[0]}", null)
                                            printText("\nLL - ${banker[1]}\n", null)
                                            if (winClaimedResponseData.responseData.panelData[i].quickPick) {
                                                printColumnsString(
                                                    arrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    ),
                                                    intArrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                                    ),
                                                    intArrayOf(0, 2), null
                                                )

                                            } else {
                                                printColumnsString(
                                                    arrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    ),
                                                    intArrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}".length,
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                                    ),
                                                    intArrayOf(0, 2), null
                                                )

                                            }
                                            printColumnsString(
                                                arrayOf(
                                                    "No of lines",
                                                    "${winClaimedResponseData.responseData.panelData[i].numberOfLines}"
                                                ),
                                                intArrayOf(
                                                    "No of lines".length,
                                                    "${winClaimedResponseData.responseData.panelData[i].numberOfLines}".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                            printText("\n----------------------------", null)
                                            amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines

                                        } else {
                                            printText(
                                                "\n${winClaimedResponseData.responseData.panelData[i].pickedValues}\n",
                                                null
                                            )
                                            if (winClaimedResponseData.responseData.gameCode == "DailyLotto") {
                                                val doubleJackpotImage: Bitmap =
                                                    if (winClaimedResponseData.responseData.panelData[i].doubleJackpot) {
                                                        jackpotDoubleEnableResizedBitmap
                                                    } else {
                                                        jackpotDoubleDisableResizedBitmap
                                                    }
                                                val secureJackpotImage: Bitmap =
                                                    if (winClaimedResponseData.responseData.panelData[i].secureJackpot) {
                                                        jackpotSecureEnableResizedBitmap
                                                    } else {
                                                        jackpotSecureDisableResizedBitmap
                                                    }
                                                printBitmapCustom(doubleJackpotImage, 1, null)
                                                printText("\n", null)
                                                printText("${winClaimedResponseData.responseData.doubleJackpotAmount} $currencyCode", null)
                                                printBitmapCustom(secureJackpotImage, 1, null)
                                                printText("\n", null)
                                                printText("${winClaimedResponseData.responseData.secureJackpotAmount} $currencyCode", null)
                                                printText("\n", null)
                                            }
                                            if (winClaimedResponseData.responseData.panelData[i].quickPick) {
                                                printColumnsString(
                                                    arrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    ),
                                                    intArrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                                    ),
                                                    intArrayOf(0, 2), null
                                                )

                                            } else {
                                                printColumnsString(
                                                    arrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    ),
                                                    intArrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}".length,
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                                    ),
                                                    intArrayOf(0, 2), null
                                                )

                                            }
                                            printColumnsString(
                                                arrayOf(
                                                    "No of lines",
                                                    "${winClaimedResponseData.responseData.panelData[i].numberOfLines}"
                                                ),
                                                intArrayOf(
                                                    "No of lines".length,
                                                    "${winClaimedResponseData.responseData.panelData[i].numberOfLines}".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )
                                            printText("\n----------------------------", null)
                                            if (winClaimedResponseData.responseData.gameCode == "DailyLotto") {
                                                var panelAmount = 0.0
                                                var doubleJackpotPanelAmount = 0.0
                                                var secureJackpotPanelAmount = 0.0
                                                panelAmount =
                                                    (winClaimedResponseData.responseData.panelData[i].unitCost) * (winClaimedResponseData.responseData.panelData[i].betAmountMultiple) * (winClaimedResponseData.responseData.panelData[i].numberOfLines)
                                                if (winClaimedResponseData.responseData.panelData[i].doubleJackpot) {
                                                    doubleJackpotPanelAmount =
                                                        panelAmount * winClaimedResponseData.responseData.doubleJackpotAmount
                                                }
                                                if (winClaimedResponseData.responseData.panelData[i].secureJackpot) {
                                                    secureJackpotPanelAmount =
                                                        panelAmount * winClaimedResponseData.responseData.secureJackpotAmount
                                                }
                                                amount += panelAmount + doubleJackpotPanelAmount + secureJackpotPanelAmount;
                                            } else {
                                                amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines
                                            }
                                        }

                                    } else if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                            "Market",
                                            ignoreCase = true
                                        )
                                    ) {
                                        printText(
                                            "\n${winClaimedResponseData.responseData.panelData[i].betDisplayName}\n",
                                            null
                                        )
                                        printColumnsString(
                                            arrayOf(
                                                winClaimedResponseData.responseData.panelData[i].pickDisplayName,
                                                "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                            ),
                                            intArrayOf(
                                                winClaimedResponseData.responseData.panelData[i].pickDisplayName.length,
                                                "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                        printColumnsString(
                                            arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                            intArrayOf(
                                                "No of lines".length,
                                                "${panelData[i].numberOfLines}".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                        printText("\n----------------------------", null)
                                        amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines
                                    }
                                }
                            }
                        }

                        setAlignment(0, null)
                        printText("\n", null)
                        printColumnsString(
                            arrayOf("Amount", "$amount"),
                            intArrayOf("Amount".length, "$amount".length),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf(
                                "No of Draws(s)",
                                "${winClaimedResponseData.responseData.drawData.size}"
                            ),
                            intArrayOf(
                                "No of Draws(s)".length,
                                "${winClaimedResponseData.responseData.drawData.size}".length
                            ),
                            intArrayOf(0, 2), null
                        )
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf(
                                "TOTAL AMOUNT",
                                "${winClaimedResponseData.responseData.totalPurchaseAmount} $currencyCode"
                            ),
                            intArrayOf(
                                "TOTAL AMOUNT".length,
                                "${winClaimedResponseData.responseData.totalPurchaseAmount} $currencyCode".length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printText("\n", null)
                        setAlignment(1, null)
                        printBitmapCustom(qrCodeHelperObject.qrcOde, 1, null)
                        sendRAWData(boldFontDisable, null)
                        printText("\n${winClaimedResponseData.responseData.ticketNumber}", null)
                        printText("\n$username\n", null)
                        printText("------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(28)
                                    addString("")
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(winClaimedResponseData.responseData.gameName)
                                    setTextSize(22)
                                    addString(printDashStringData(getPaperLength()))
                                    setBold(true)
                                    setItalic(true)
                                    addString("Ticket Number")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(lastWinningSaleTicketNo.toString())
                                    setTextSize(22)
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    addString("                                     ")
                                    setAlgin(0)
                                    setTextSize(22)
                                    for (i in winClaimedResponseData.responseData.drawData) {
                                        addString(
                                            printTwoStringStringData(
                                                "Draw Date",
                                                getFormattedDateForWinClaim(i.drawDate)
                                            )
                                        )
                                        addString(printTwoStringStringData("Draw Time", i.drawTime))
                                        addString(
                                            printTwoStringStringData(
                                                "Win Status",
                                                i.winStatus
                                            )
                                        )
                                        addString(
                                            printTwoStringStringData(
                                                "Winning Amount",
                                                "${i.winningAmount} ${currencyCode}"
                                            )
                                        )
                                        var status = "UNCLAIMED"
                                        for (panelWinData in i.panelWinList) {
                                            if (panelWinData.status == "CLAIMED") {
                                                status = "CLAIMED"
                                                break
                                            }
                                        }
                                        addString(
                                            printTwoStringStringData(
                                                "Claim Status",
                                                "$status"
                                            )
                                        )
                                        addString(printLineStringData(getPaperLength()))
                                        addString("\n")
                                        if (i.winStatus.equals("RESULT AWAITED", true)) {
                                            isReprint = true
                                        }
                                    }
                                    setAlgin(1)
                                    setBold(false)
                                    setTextSize(24)
                                    if (isReprint) {
                                        setAlgin(1)
                                        setBold(true)
                                        setTextSize(24)
                                        addString("Reprint Ticket")
                                        addString("__________________")
                                        addString("")
                                        var amount = 0.0
                                        var numberString: String
                                        setBold(false)
                                        if (winClaimedResponseData.responseData.gameCode == "ThaiLottery") {
                                            for (i in 0 until winClaimedResponseData.responseData.panelData.size) {
                                                if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                                        "Number",
                                                        ignoreCase = true
                                                    )
                                                ) {
                                                    addString(winClaimedResponseData.responseData.panelData[i].pickedValues)
                                                    addString(
                                                        printTwoStringStringData(
                                                            "${winClaimedResponseData.responseData.panelData[i].pickDisplayName} : ${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                            "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                        )
                                                    )
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${winClaimedResponseData.responseData.panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    if (i != winClaimedResponseData.responseData.panelData.size - 1) addString(
                                                        printDashStringData(getPaperLength())
                                                    )
                                                    amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines
                                                }
                                            }
                                        } else {
                                            val panelDataList =
                                                winClaimedResponseData.responseData.panelData;
                                            panelDataList.let { mPanelData ->
                                                for (i in 0 until mPanelData.size) {
                                                    val isQp =
                                                        if (winClaimedResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                                    if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                                            "Number",
                                                            ignoreCase = true
                                                        )
                                                    ) {
                                                        if (winClaimedResponseData.responseData.panelData[i].pickType.equals(
                                                                "Banker",
                                                                ignoreCase = true
                                                            )
                                                        ) {
                                                            numberString =
                                                                winClaimedResponseData.responseData.panelData[i].pickedValues
                                                            val banker: Array<String> =
                                                                numberString.split("-")
                                                                    .toTypedArray()

                                                            addString("UL - ${banker[0]}")
                                                            addString("LL - ${banker[1]}")
                                                            if (winClaimedResponseData.responseData.panelData[i].quickPick) {
                                                                addString(
                                                                    printTwoStringStringData(
                                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                        "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                                    )
                                                                )

                                                            } else {
                                                                addString(
                                                                    printTwoStringStringData(
                                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                                        "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                                    )
                                                                )

                                                            }
                                                            addString(
                                                                printTwoStringStringData(
                                                                    "No of lines",
                                                                    "${mPanelData[i].numberOfLines}"
                                                                )
                                                            )
                                                            addString(
                                                                printDashStringData(
                                                                    getPaperLength()
                                                                )
                                                            )
                                                            amount += mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines

                                                        } else {
                                                            addString(mPanelData[i].pickedValues)
                                                            if (winClaimedResponseData.responseData.gameCode == "DailyLotto") {
                                                                val doubleJackpotImage: Bitmap =
                                                                    if (winClaimedResponseData.responseData.panelData[i].doubleJackpot) {
                                                                        jackpotDoubleEnableResizedBitmap
                                                                    } else {
                                                                        jackpotDoubleDisableResizedBitmap
                                                                    }
                                                                val secureJackpotImage: Bitmap =
                                                                    if (winClaimedResponseData.responseData.panelData[i].secureJackpot) {
                                                                        jackpotSecureEnableResizedBitmap
                                                                    } else {
                                                                        jackpotSecureDisableResizedBitmap
                                                                    }
                                                                printLogo(doubleJackpotImage, true)
                                                                endLine()
                                                                addString("${winClaimedResponseData.responseData.doubleJackpotAmount} $currencyCode")
                                                                endLine()
                                                                printLogo(secureJackpotImage, true)
                                                                endLine()
                                                                addString("${winClaimedResponseData.responseData.secureJackpotAmount} $currencyCode")
                                                            }

                                                            if (winClaimedResponseData.responseData.panelData[i].quickPick) {
                                                                addString(
                                                                    printTwoStringStringData(
                                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                        "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                                    )
                                                                )

                                                            } else {
                                                                addString(
                                                                    printTwoStringStringData(
                                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                                        "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                                    )
                                                                )

                                                            }
                                                            addString(
                                                                printTwoStringStringData(
                                                                    "No of lines",
                                                                    "${mPanelData[i].numberOfLines}"
                                                                )
                                                            )
                                                            if (i != mPanelData.size - 1) addString(
                                                                printDashStringData(getPaperLength())
                                                            )
                                                            if (winClaimedResponseData.responseData.gameCode == "DailyLotto") {
                                                                var panelAmount = 0.0
                                                                var doubleJackpotPanelAmount = 0.0
                                                                var secureJackpotPanelAmount = 0.0
                                                                panelAmount =
                                                                    (winClaimedResponseData.responseData.panelData[i].unitCost) * (winClaimedResponseData.responseData.panelData[i].betAmountMultiple) * (winClaimedResponseData.responseData.panelData[i].numberOfLines)
                                                                if (winClaimedResponseData.responseData.panelData[i].doubleJackpot) {
                                                                    doubleJackpotPanelAmount =
                                                                        panelAmount * winClaimedResponseData.responseData.doubleJackpotAmount
                                                                }
                                                                if (winClaimedResponseData.responseData.panelData[i].secureJackpot) {
                                                                    secureJackpotPanelAmount =
                                                                        panelAmount * winClaimedResponseData.responseData.secureJackpotAmount
                                                                }
                                                                amount += panelAmount + doubleJackpotPanelAmount + secureJackpotPanelAmount;
                                                            } else {
                                                                amount += mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines
                                                            }
                                                        }

                                                    } else if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                                            "Market",
                                                            ignoreCase = true
                                                        )
                                                    ) {
                                                        addString(winClaimedResponseData.responseData.panelData[i].betDisplayName)
                                                        addString(
                                                            printTwoStringStringData(
                                                                winClaimedResponseData.responseData.panelData[i].pickDisplayName,
                                                                "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )
                                                        addString(
                                                            printTwoStringStringData(
                                                                "No of lines",
                                                                "${mPanelData[i].numberOfLines}"
                                                            )
                                                        )
                                                        if (i != mPanelData.size - 1) addString(
                                                            printDashStringData(getPaperLength())
                                                        )
                                                        amount += mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines
                                                    }
                                                }
                                            }
                                        }
                                        addString(printLineStringData(getPaperLength()))
                                        setTextSize(24)
                                        setAlgin(0)
                                        addString(printTwoStringStringData("Amount", "$amount"))
                                        addString(
                                            printTwoStringStringData(
                                                "No of Draws(s)",
                                                "${winClaimedResponseData.responseData.drawData.size}"
                                            )
                                        )
                                        setBold(true)
                                        addString(
                                            printTwoStringStringData(
                                                "TOTAL AMOUNT",
                                                "${winClaimedResponseData.responseData.totalPurchaseAmount} $currencyCode"
                                            )
                                        )
                                        setBold(false)
                                        addString(" ")
                                        setAlgin(1)
                                        printLogo(qrCodeHelperObject.qrcOde, true)
                                        addString(winClaimedResponseData.responseData.ticketNumber)
                                        addString("")
                                        addString("$username")
                                        addString("Ticket Validity : ${winClaimedResponseData.responseData.ticketExpiry}")
                                        addString("    ")
                                        addString("- - - - For Demo - - - -")
                                        addString("\n")
                                    }
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)

                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
                else if (call.method == "balanceInvoiceReport") {

                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 280, 70, false)

                    mSunmiPrinterService?.run {
                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\nBalance/Invoice Report\n", null)
                        sendRAWData(boldFontDisable, null)
                        setAlignment(1, null)
                        printText("$balanceInvoiceToAndFromDate", null)
                        printText("\n-------------------------\n", null)
                        printText("Org Id : " + orgId.toString(), null)
                        printText("\n", null)
                        printText("Organization Name : " + orgName.toString(), null)
                        printText("\n-------------------------\n", null)
                        printColumnsString(
                            arrayOf(
                                "Opening Balance",
                                balanceInvoiceResponseReport?.openingBalance.toString()
                            ),
                            intArrayOf(
                                "Opening Balance".length,
                                balanceInvoiceResponseReport?.openingBalance.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf(
                                "Closing Balance",
                                balanceInvoiceResponseReport?.closingBalance.toString()
                            ),
                            intArrayOf(
                                "Closing Balance".length,
                                balanceInvoiceResponseReport?.closingBalance.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printText("\n-------------------------\n", null)
                        printColumnsString(
                            arrayOf("Sales", balanceInvoiceResponseReport?.sales.toString()),
                            intArrayOf(
                                "Sales".length,
                                balanceInvoiceResponseReport?.sales.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf("Claims", balanceInvoiceResponseReport?.claims.toString()),
                            intArrayOf(
                                "Claims".length,
                                balanceInvoiceResponseReport?.claims.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf("Claim Tax", balanceInvoiceResponseReport?.claimTax.toString()),
                            intArrayOf(
                                "Claim Tax".length,
                                balanceInvoiceResponseReport?.claimTax.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf(
                                "Commission Sales",
                                balanceInvoiceResponseReport?.salesCommission.toString()
                            ),
                            intArrayOf(
                                "Commission Sales".length,
                                balanceInvoiceResponseReport?.salesCommission.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf(
                                "Commission Winnings",
                                balanceInvoiceResponseReport?.winningsCommission.toString()
                            ),
                            intArrayOf(
                                "Commission Winnings".length,
                                balanceInvoiceResponseReport?.winningsCommission.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf("Payments", balanceInvoiceResponseReport?.payments.toString()),
                            intArrayOf(
                                "Payments".length,
                                balanceInvoiceResponseReport?.payments.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf(
                                "Debit/Credit txn",
                                balanceInvoiceResponseReport?.creditDebitTxn.toString()
                            ),
                            intArrayOf(
                                "Debit/Credit txn".length,
                                balanceInvoiceResponseReport?.creditDebitTxn.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printText("\n-------------------------\n", null)
                        printText("------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)


                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(22)
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(" ")
                                    addString("Balance/Invoice Report")
                                    setBold(true)
                                    setItalic(true)
                                    addString(balanceInvoiceToAndFromDate.toString())
                                    setItalic(false)
                                    setBold(false)
                                    setTextSize(24)
                                    addString(printDashStringData(getPaperLength()))
                                    setBold(false)
                                    setAlgin(0)
                                    setTextSize(20)
                                    addString(
                                        "${"Org Id : " + orgId.toString()}"
                                    )
                                    addString(
                                        "${"Organization Name : " + orgName.toString()}"
                                    )
                                    setTextSize(24)
                                    setAlgin(0)
                                    addString(printDashStringData(getPaperLength()))
                                    setTextSize(22)
                                    addString(
                                        printTwoStringStringData(
                                            "Opening Balance",
                                            balanceInvoiceResponseReport?.openingBalance.toString()
                                        )
                                    )
                                    addString(
                                        printTwoStringStringData(
                                            "Closing Balance",
                                            balanceInvoiceResponseReport?.closingBalance.toString()
                                        )
                                    )
                                    setBold(false)
                                    setItalic(false)
                                    setAlgin(0)
                                    setTextSize(24)
                                    addString(printDashStringData(getPaperLength()))
                                    setBold(false)
                                    setTextSize(22)
                                    addString(
                                        printTwoStringStringData(
                                            "Sales",
                                            balanceInvoiceResponseReport?.sales.toString()
                                        )
                                    )
                                    addString(
                                        printTwoStringStringData(
                                            "Claims",
                                            balanceInvoiceResponseReport?.claims.toString()

                                        )
                                    )
                                    addString(
                                        printTwoStringStringData(
                                            "Claim Tax",
                                            balanceInvoiceResponseReport?.claimTax.toString()

                                        )
                                    )
                                    addString(
                                        printTwoStringStringData(
                                            "Commission Sales",
                                            balanceInvoiceResponseReport?.salesCommission.toString()

                                        )
                                    )

                                    addString(
                                        printTwoStringStringData(
                                            "Commission Winnings",
                                            balanceInvoiceResponseReport?.winningsCommission.toString()

                                        )
                                    )

                                    addString(
                                        printTwoStringStringData(
                                            "Payments",
                                            balanceInvoiceResponseReport?.payments.toString()

                                        )
                                    )

                                    addString(
                                        printTwoStringStringData(
                                            "Debit/Credit txn",
                                            balanceInvoiceResponseReport?.creditDebitTxn.toString()

                                        )
                                    )
                                    setTextSize(24)
                                    addString(printLineStringData(getPaperLength()))
                                    addString(" ")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)

                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
                else if (call.method == "operationalCashReport") {

                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 280, 70, false)

                    mSunmiPrinterService?.run {
                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\nOperational Cash Report\n", null)
                        sendRAWData(boldFontDisable, null)
                        setAlignment(1, null)
                        printText("$balanceInvoiceToAndFromDate", null)
                        printText("\n-------------------------\n", null)
                        printText("Org Id : " + orgId.toString(), null)
                        printText("\n", null)
                        printText("Organization Name : " + orgName.toString(), null)
                        printText("\n-------------------------\n", null)

                        for (i in 0 until operationalCashReport.gameWiseData.size) {
                            setAlignment(1, null)
                            val opCashRepGameWiseData = operationalCashReport.gameWiseData[i]
                            printText("\n${opCashRepGameWiseData.gameName}\n", null)
                            printColumnsString(
                                arrayOf("Sales", opCashRepGameWiseData.sales.toString()),
                                intArrayOf(
                                    "Sales".length,
                                    opCashRepGameWiseData.sales.toString().length
                                ),
                                intArrayOf(0, 2), null
                            )
                            printColumnsString(
                                arrayOf("Claims", opCashRepGameWiseData.claims.toString()),
                                intArrayOf(
                                    "Claims".length,
                                    opCashRepGameWiseData.claims.toString().length
                                ),
                                intArrayOf(0, 2), null
                            )
                            printColumnsString(
                                arrayOf("Claim Tax", opCashRepGameWiseData.claimTax.toString()),
                                intArrayOf(
                                    "Claim Tax".length,
                                    opCashRepGameWiseData.claimTax.toString().length
                                ),
                                intArrayOf(0, 2), null
                            )
                            printText("\n-------------------------\n", null)
                        }
                        setAlignment(1, null)
                        printText("\nTotal\n", null)
                        printColumnsString(
                            arrayOf("Sales", operationalCashReport?.totalSale.toString()),
                            intArrayOf(
                                "Sales".length,
                                operationalCashReport?.totalSale.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf("Claims", operationalCashReport?.totalClaim.toString()),
                            intArrayOf(
                                "Claims".length,
                                operationalCashReport?.totalClaim.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf("Claim Tax", operationalCashReport?.totalClaimTax.toString()),
                            intArrayOf(
                                "Claim Tax".length,
                                operationalCashReport?.totalClaimTax.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf(
                                "Commission Sales",
                                operationalCashReport?.salesCommision.toString()
                            ),
                            intArrayOf(
                                "Commission Sales".length,
                                operationalCashReport?.salesCommision.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf(
                                "Commission Winnings",
                                operationalCashReport?.winningsCommision.toString()
                            ),
                            intArrayOf(
                                "Commission Winnings".length,
                                operationalCashReport?.winningsCommision.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf(
                                "Cash On Hand",
                                operationalCashReport?.totalCashOnHand.toString()
                            ),
                            intArrayOf(
                                "Cash On Hand".length,
                                operationalCashReport?.totalCashOnHand.toString().length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printText("\n-------------------------\n", null)
                        printText("------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)


                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(22)
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(" ")
                                    addString(
                                        "Operational Cash Report",
                                    )
                                    setBold(true)
                                    setItalic(true)
                                    addString(balanceInvoiceToAndFromDate.toString())
                                    setItalic(false)
                                    setBold(false)
                                    setTextSize(24)
                                    addString(printDashStringData(getPaperLength()))
                                    setBold(false)
                                    setAlgin(0)
                                    setTextSize(20)
                                    addString(
                                        "${"Org Id : " + orgId.toString()}"
                                    )
                                    addString(
                                        "${"Organization Name : " + orgName.toString()}"
                                    )
                                    setTextSize(24)
                                    setAlgin(0)
                                    addString(printDashStringData(getPaperLength()))
                                    setTextSize(24)
                                    for (data in operationalCashReport.gameWiseData) {
                                        setAlgin(1)
                                        setBold(true)
                                        addString(data.gameName)
                                        setBold(false)
                                        setBold(false)
                                        setItalic(false)
                                        setAlgin(0)
                                        setTextSize(24)
                                        addString(
                                            printTwoStringStringData(
                                                "Sales",
                                                data.sales.toString()

                                            )
                                        )
                                        addString(
                                            printTwoStringStringData(
                                                "Claims",
                                                data.claims.toString()

                                            )
                                        )
                                        addString(
                                            printTwoStringStringData(
                                                "Claim Tax",
                                                data.claimTax.toString()

                                            )
                                        )
                                        addString(printDashStringData(getPaperLength()))
                                    }
                                    setAlgin(1)
                                    setBold(true)
                                    addString("ToTal")
                                    setBold(false)
                                    setItalic(false)
                                    setAlgin(0)
                                    setTextSize(22)
                                    addString(
                                        printTwoStringStringData(
                                            "Sales",
                                            operationalCashReport?.totalSale.toString()

                                        )
                                    )
                                    addString(
                                        printTwoStringStringData(
                                            "Claims",
                                            operationalCashReport?.totalClaim.toString()

                                        )
                                    )
                                    addString(
                                        printTwoStringStringData(
                                            "Claim Tax",
                                            operationalCashReport?.totalClaimTax.toString()

                                        )
                                    )
                                    addString(
                                        printTwoStringStringData(
                                            "Commission Sales",
                                            operationalCashReport?.salesCommision.toString()

                                        )
                                    )

                                    addString(
                                        printTwoStringStringData(
                                            "Commission Winnings",
                                            operationalCashReport?.winningsCommision.toString()

                                        )
                                    )

                                    addString(
                                        printTwoStringStringData(
                                            "Cash On Hand",
                                            operationalCashReport?.totalCashOnHand.toString()

                                        )
                                    )
                                    setTextSize(24)
                                    addString(printLineStringData(getPaperLength()))
                                    addString(" ")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)

                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
            }
        }

        channel_print = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mChannelForPrint)

        channel_print.setMethodCallHandler { call, result ->

            val argument = call.arguments as Map<*, *>
            val userName = argument["userName"]
            val userId = argument["userId"]
            val currencyCode = argument["currencyCode"]
            val amount = argument["Amount"]
            val url = argument["url"]
            val couponCode = argument["couponCode"]
            val bitmap =
                BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
            val logo = Bitmap.createScaledBitmap(bitmap, 280, 70, false)
            val bitmapEighteenPlus =
                BitmapFactory.decodeResource(context.resources, R.drawable.eighteen_plus)
            val logoEighteenPlus = Bitmap.createScaledBitmap(bitmapEighteenPlus, 100, 100, false)

            if (call.method == "notificationPrint") {
                Log.d("TAg", "configureFlutterEngine: notificationPrint method")
                Glide.with(context).asBitmap().load(url).into(object : CustomTarget<Bitmap>() {
                    override fun onResourceReady(
                        resource: Bitmap,
                        transition: com.bumptech.glide.request.transition.Transition<in Bitmap>?
                    ) {
                        val recreatedQrBitmap = Bitmap.createScaledBitmap(resource, 450, 450, true)
                        mSunmiPrinterService?.run {
                            enterPrinterBuffer(true)
                            setAlignment(1, null)
                            printBitmapCustom(logo, 1, null)
                            sendRAWData(boldFontEnable, null)
                            setFontSize(32f, null)
                            printText("\n\n---- ${userName} -----", null)
                            sendRAWData(boldFontDisable, null)
                            setFontSize(27f, null)
                            printText("\n${if (userId != 0) "ID : ${userId}" else ""}", null)
                            sendRAWData(boldFontEnable, null)
                            setFontSize(27f, null)
                            printText("\nTicket: ", null)
                            printText("\n$couponCode", null)
                            setFontSize(48f, null)
                            printText("\n Amount: $currencyCode ${amount} ", null)
                            sendRAWData(boldFontDisable, null)
                            printBitmapCustom(recreatedQrBitmap, 0, null)
                            setFontSize(27f, null)
                            printText("\nDate : ${getCurrentDateTime()}\n", null)
                            //printText("\n-------------------------\n", null)
                            sendRAWData(boldFontEnable, null)
                            setFontSize(23f, null)
                            setAlignment(0, null)
//                            printText(
//                                "*Note : Please always keep this \nreceipt with you when you want\n cash out your remaining game\n balance.",
//                                null
//                            )
//                            printText(" Go to game portal for \ninitiate withdrawal.", null)
                            printText(
                                "*Note: The validity of this ticket is 7 days; passed this time,\n" + "ticket lost its value.WLS Games\n" + " decline all responsibility given to the " + "Degradation or loss of ticket.",
                                null
                            )
                            printText(
                                " PLEASE PRESENT THIS TICKET AT THE CASHIER FOR THE " + "WITHDRAWAL OF THE BALANCE FROM\nYOUR GAME ACCOUNT",
                                null
                            )
                            sendRAWData(boldFontDisable, null)
                            setAlignment(1, null)
                            printText("\n", null)
                            printBitmapCustom(logoEighteenPlus, 1, null)
                            printText("\n--------------------------\n", null)
                            printText("\n\n", null)
                            exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                                override fun onRunResult(isSuccess: Boolean) {}

                                override fun onReturnString(result: String?) {}

                                override fun onRaiseException(code: Int, msg: String?) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")
                                }

                                override fun onPrintResult(code: Int, msg: String?) {
                                    if (updatePrinterState() != 1) {
                                        activity.runOnUiThread {
                                            Toast.makeText(
                                                activity,
                                                "Something went wrong while printing, Please try again",
                                                Toast.LENGTH_SHORT
                                            ).show()
                                        }
                                        result.error(
                                            "-1",
                                            msg,
                                            "Something went wrong while printing"
                                        )

                                    } else {
                                        activity.runOnUiThread {
                                            Toast.makeText(
                                                activity, "Successfully printed", Toast.LENGTH_SHORT
                                            ).show()
                                        }
                                        result.success(true)
                                    }
                                }
                            })

                        } ?: this.let {


                            if (getDeviceName() == "QUALCOMM M1") {
                                val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                                try {
                                    usbThermalPrinter.run {
                                        reset()
                                        start(1)
                                        setGray(1)
                                        setAlgin(1)
                                        printLogo(logo, true)
                                        setTextSize(32)
                                        setBold(true)
                                        setAlgin(1)
                                        setTextSize(27)
                                        addString("---- ${userName} -----")
                                        //addString(if (userId != 0) "ID : ${userId}" else "")
                                        //addString(" ")
                                        setTextSize(22)
                                        setAlgin(1)
                                        addString("Ticket: $couponCode")
                                        //addString(" ")
                                        setTextSize(34)
                                        setAlgin(1)
                                        addString("Amount: $currencyCode $amount")
                                        setGray(0)
                                        setAlgin(1)
                                        printLogo(recreatedQrBitmap, true)
                                        setBold(true)
                                        setTextSize(22)
                                        addString("Date : ${getCurrentDateTime()}")
                                        setBold(false)
                                        setTextSize(20)
//                                        addString(printDashStringData(getPaperLength()))
//                                        setTextSize(20)
                                        // addString("*Note : Please always keep this \n" + "receipt with you when you want\n" + " cash out your remaining game\n" + " balance. Go to game portal for " + "initiate withdrawal.")
                                        addString(
                                            "*Note: The validity of this ticket is 7 days; passed this time,\n" + "ticket lost its value.WLS Games\n" + " decline all responsibility given to the " + "Degradation or loss of ticket."
                                        )
                                        addString(
                                            "PLEASE PRESENT THIS TICKET AT THE CASHIER FOR THE " + "WITHDRAWAL OF THE BALANCE FROM\nYOUR GAME ACCOUNT"
                                        )
                                        setAlgin(1)
                                        printLogo(logoEighteenPlus, true)
                                        setTextSize(24)
                                        addString(printDashStringData(getPaperLength()))
                                        addString("\n")
                                        printString()
                                        activity.runOnUiThread {
                                            Toast.makeText(
                                                activity, "Successfully printed", Toast.LENGTH_SHORT
                                            ).show()
                                        }
                                        result.success(true)
                                    }


                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            } else if (getDeviceName() == "Centerm CTA Q7") {
                                val callback =
                                    object : com.pos.sdk.printer.InnerResultCallback.Stub() {
                                        @Throws(RemoteException::class)
                                        override fun onRunResult(b: Boolean) {
                                            //showNormalMessage(getString(R.string.tips_task_result) + b)
                                        }

                                        @Throws(RemoteException::class)
                                        override fun onReturnString(s: String) {
                                            // showNormalMessage(getString(R.string.tips_task_feedback) + s)
                                        }

                                        @Throws(RemoteException::class)
                                        override fun onRaiseException(i: Int, s: String) {
                                            /*          showErrorMessage(getString(R.string.tips_task_exception))
                                                      showErrorMessage(getString(R.string.tips_error_code) + i)
                                                      showErrorMessage(getString(R.string.tips_error_msg) + s)*/
                                        }
                                    }

                                try {
                                    if (mPrinter!!.isLabelMode) {
                                        result.error(
                                            "-1",
                                            "Unable to find printer",
                                            "no usb thermal printer"
                                        )
                                    } else {

                                        mPrinter!!.printBitmap(logo, callback)
                                        mPrinter!!.setStyleBold(true)
                                        mPrinter!!.setFontSize(22)
                                        mPrinter!!.setAlign(PrinterDevice.AlignType.CENTER)
                                        mPrinter!!.printText("\n\n---- ${userName} -----", callback)
                                        mPrinter!!.printText(
                                            "\n${if (userId != 0) "ID : ${userId}" else ""}",
                                            callback
                                        )
                                        mPrinter!!.printText("\nTicket: ", callback)
                                        mPrinter!!.printText("\n$couponCode", callback)
                                        mPrinter!!.printText(
                                            "\n Amount: $currencyCode ${amount} ",
                                            null
                                        )
                                        mPrinter!!.printBitmap(recreatedQrBitmap, callback)
                                        mPrinter!!.printText(
                                            "\nDate : ${getCurrentDateTime()}\n",
                                            callback
                                        )
                                        mPrinter!!.setStyleBold(false)
                                        mPrinter!!.setFontSize(18)
                                        mPrinter!!.printText(
                                            "*Note: The validity of this ticket is 7 days; passed this time,\n" + "ticket lost its value.WLS Games\n" + " decline all responsibility given to the " + "Degradation or loss of ticket.",
                                            callback
                                        )
                                        mPrinter!!.printText(
                                            "PLEASE PRESENT THIS TICKET AT THE CASHIER FOR THE " + "WITHDRAWAL OF THE BALANCE FROM\nYOUR GAME ACCOUNT\n",
                                            callback
                                        )
                                        mPrinter!!.printBitmap(logoEighteenPlus, callback)
                                        mPrinter!!.printText(
                                            "\n--------------------------",
                                            object :
                                                com.pos.sdk.printer.InnerResultCallback.Stub() {
                                                @Throws(RemoteException::class)
                                                override fun onRunResult(b: Boolean) {
                                                    //showNormalMessage(getString(R.string.tips_task_result) + b)
                                                    Log.d("test", "onRunResult----------")
                                                    result.success(true)

                                                }

                                                @Throws(RemoteException::class)
                                                override fun onReturnString(s: String) {
                                                    // showNormalMessage(getString(R.string.tips_task_feedback) + s)
                                                    Log.d("test", "onReturnString----------")

                                                }

                                                @Throws(RemoteException::class)
                                                override fun onRaiseException(i: Int, s: String) {
                                                    Log.d("test", "onRaiseException----------")

                                                    /*          showErrorMessage(getString(R.string.tips_task_exception))
                                                              showErrorMessage(getString(R.string.tips_error_code) + i)
                                                              showErrorMessage(getString(R.string.tips_error_msg) + s)*/
                                                }
                                            })


                                    }

                                } catch (e: java.lang.Exception) {
                                    e.printStackTrace()
                                    result.error(
                                        "-1",
                                        "error",
                                        "error"
                                    )
                                }


                            } else {
                                Log.d("TAg", "configureFlutterEngine: no printer")
                                result.error(
                                    "-1",
                                    "Unable to find printer",
                                    "no sunmi or no usb thermal printer"
                                )
                            }
                        }
                    }

                    override fun onLoadCleared(placeholder: Drawable?) {

                    }

                });
            }
        }


        channel_afterWithdrawal =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mChannelForAppAfterWithdrawal)

        channel_afterWithdrawal.setMethodCallHandler { call, result ->
            val argument = call.arguments!! as Map<*, *>;
            val username = argument["username"]
            val withdrawalAmt = argument["withdrawalAmt"]


            if (call.method == "afterWithdrawal") {
                Log.d("TaG", "<-- afterWithdrawal -->")
                val bitmap =
                    BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 280, 70, false)

                mSunmiPrinterService?.run {

                    enterPrinterBuffer(true)
                    setAlignment(1, null)
                    printBitmapCustom(resizedBitmap, 1, null)
                    sendRAWData(boldFontEnable, null)
                    setFontSize(24f, null)
                    printText("\n\nWithdrawal Confirmation", null)
                    sendRAWData(boldFontDisable, null)
                    printText("\nPurchase Time", null)
                    val purchaseDate: String = "24/ 09/ 2023"
                    val purchaseTime: String = "30/ 09/ 2023"
                    printText(
                        "\n${getFormattedDate(purchaseDate)} ${getFormattedTime(purchaseTime)}",
                        null
                    )
                    sendRAWData(boldFontEnable, null)
                    printText("\n\n", null)
                    exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                        override fun onRunResult(isSuccess: Boolean) {}

                        override fun onReturnString(result: String?) {}

                        override fun onRaiseException(code: Int, msg: String?) {
                            activity.runOnUiThread {
                                Toast.makeText(
                                    activity,
                                    "Something went wrong while printing, Please try again",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                            result.error("-1", msg, "Something went wrong while printing")
                        }

                        override fun onPrintResult(code: Int, msg: String?) {
                            if (updatePrinterState() != 1) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")

                            } else {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity, "Successfully printed", Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)
                            }
                        }
                    })
                } ?: this.let {
                    val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                    if (getDeviceName() == "QUALCOMM M1") {
                        usbThermalPrinter.run {
                            try {
                                reset()
                                start(1)
                                setTextSize(28)
                                setBold(false)
                                setGray(1)
                                setAlgin(1)
                                printLogo(resizedBitmap, true)
                                addString("---- $username -----")
                                setBold(true)
                                setTextSize(20)
                                addString("Date : ${getCurrentDateTime()}")
                                setTextSize(22)
                                addString("Withdrawal amount : $withdrawalAmt")
                                setTextSize(22)
                                setItalic(true)
                                addString("-------* * *-------")
                                addString("\n")
                                printString()
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity, "Successfully printed", Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)

                            } catch (e: java.lang.Exception) {
                                showMsgAccordingToException(e as CommonException, result)
                                stop()
                                e.printStackTrace()
                            }
                        }

                    } else {
                        android.util.Log.d("TAg", "configureFlutterEngine: no printer")
                        result.error(
                            "-1", "Unable to find printer", "no sunmi or no usb thermal printer"
                        )
                    }
                }
            }
        }
    }

    private fun getSelectedOptionsAddOn(options: List<SportsPoolSaleResponse.ResponseData.AddOnDrawData.Board.Event.Option>): String {
        Log.d("TAg", "optionsAddOn: $options")
        // var selectionOptions = ""
        val selectionOptions = StringBuffer()
        selectionOptions.append(" - ")
        for ((index, element) in options.withIndex()) {
            Log.d("TAg", " element.code AddOn: ${element.code}")
            selectionOptions.append(element.code)
            if (index < options.size - 1) {
                selectionOptions.append(", ")
            }
        }
        Log.d("TAg", "selectionOptions AddOn: $selectionOptions")
        return selectionOptions.toString()
    }

    private fun getSelectedOptions(options: List<SportsPoolSaleResponse.ResponseData.MainDrawData.Board.Event.Option>): String {
        Log.d("TAg", "options: $options")
        // var selectionOptions = ""
        val selectionOptions = StringBuffer()
        selectionOptions.append(" - ")
        for ((index, element) in options.withIndex()) {
            Log.d("TAg", " element.code AddOn: ${element.code}")
            selectionOptions.append(element.code)
            if (index < options.size - 1) {
                selectionOptions.append(", ")
            }
        }
        Log.d("TAg", "selectionOptions: $selectionOptions")
        return selectionOptions.toString()
    }

    private fun showMsgAccordingToException(
        exception: CommonException,
        result: MethodChannel.Result
    ) {

        when (exception) {
            is NoPaperException -> result.error(
                "-1",
                "Please insert the paper before printing",
                "${exception.message}"
            )

            is OverHeatException -> result.error(
                "-1",
                "Device overheated, Please try after some time.",
                "${exception.message}"
            )

            is GateOpenException -> result.error(
                "-1",
                "Something went wrong while printing",
                "${exception.message}"
            )

            is PaperCutException -> result.error(
                "-1",
                "Something went wrong while printing",
                "${exception.message}"
            )

            is TimeoutException -> result.error(
                "-1",
                "Unable to print, Please try after some time.",
                "${exception.message}"
            )

            is FontErrorException -> result.error(
                "-1",
                "Something went wrong while printing",
                "${exception.message}"
            )

            is LowPowerException -> result.error(
                "-1",
                "Low battery, Please charge the device !",
                "${exception.message}"
            )

            else -> result.error(
                "-1",
                "Something went wrong while printing",
                "${exception.message}"
            )

        }
    }

    private fun capitalize(s: String?): String {
        if (s == null || s.isEmpty()) {
            return ""
        }
        val first = s[0]
        return if (Character.isUpperCase(first)) {
            s
        } else {
            first.uppercaseChar().toString() + s.substring(1)
        }
    }

    private fun getDeviceName(): String {
        val manufacturer = Build.MANUFACTURER
        val model = Build.MODEL
        return if (model.lowercase(Locale.getDefault()).startsWith(
                manufacturer.lowercase(
                    Locale.getDefault()
                )
            )
        ) {
            capitalize(model)
        } else {
            if (model.equals("T2mini_s", ignoreCase = true)
            ) capitalize(manufacturer) + " T2mini" else capitalize(manufacturer) + " " + model
        }
    }

    private fun initializeSunmiPrinter() {
        try {
            InnerPrinterManager.getInstance().bindService(this, innerPrinterCallback)
        } catch (e: InnerPrinterException) {
            e.printStackTrace()
        }
    }

    private fun initializeCentermPrinter() {
        DevicesFactory.create(this, object : ResultCallback<DeviceManager> {
            override fun onFinish(deviceManager: DeviceManager) {
                mPrinter = deviceManager.printerDevice
            }

            override fun onError(i: Int, s: String) {
                Log.d("CentermError", "onError: $i,$s")
            }
        })
    }

    private var innerPrinterCallback: InnerPrinterCallback = object : InnerPrinterCallback() {
        override fun onConnected(sunmiPrinterService: SunmiPrinterService) {
            mSunmiPrinterService = sunmiPrinterService
        }

        override fun onDisconnected() {}
    }

    @SuppressLint("SimpleDateFormat")
    fun getFormattedDateForWinClaim(sourceDate: String): String {
        val input = SimpleDateFormat("yyyy-MM-dd")
        val output = SimpleDateFormat("MMM dd, yyyy")
        try {
            input.parse(sourceDate)?.let {
                return output.format(it)
            }
        } catch (e: Exception) {
            Log.e("log", "Date parsing error: ${e.message}")
        }
        return sourceDate
    }

    @SuppressLint("SimpleDateFormat")
    fun getFormattedDate(sourceDate: String): String {
        val input = SimpleDateFormat("dd-MM-yyyy")
        val output = SimpleDateFormat("MMM dd, yyyy")
        try {
            input.parse(sourceDate)?.let {
                return output.format(it)
            }
        } catch (e: Exception) {
            Log.e("log", "Date parsing error: ${e.message}")
        }
        return sourceDate
    }

    fun getCurrentDateTime(): String {
        val calendar = Calendar.getInstance()
        val year = calendar.get(Calendar.YEAR)
        val month = calendar.get(Calendar.MONTH) + 1 // Month is 0-based, so add 1
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        val hour = calendar.get(Calendar.HOUR_OF_DAY) // 24-hour format
        val minute = calendar.get(Calendar.MINUTE)
        val second = calendar.get(Calendar.SECOND)

        val dateTime = "$day/$month/$year $hour:$minute:$second"
        return dateTime
    }


    @SuppressLint("SimpleDateFormat")
    fun getFormattedTime(sourceTime: String): String {
        val input = SimpleDateFormat("HH:mm:ss")
        val output = SimpleDateFormat("HH:mm:ss")
        try {
            input.parse(sourceTime)?.let {
                return output.format(it)
            }
        } catch (e: Exception) {
            Log.e("log", "Date parsing error: ${e.message}")
        }
        return sourceTime
    }

    private fun getPaperLength(): Int {
        return "--------------------------".length
    }

    private fun printDashStringData(length: Int): String {
        val str = StringBuffer()
        for (i in 0..length) {
            str.append("-")
        }
        return str.toString()
    }

    private fun printLineStringData(length: Int): String {
        val str = StringBuffer()
        for (i in 0..length) {
            str.append("_")
        }
        return str.toString()
    }

    private fun printLineStarData(length: Int): String {
        val str = StringBuffer()
        for (i in 0..length) {
            str.append("*")
        }
        return str.toString()
    }

    private fun printTwoStringStringData(one: String, two: String): String {
        val str = StringBuffer()
        val spaceInBetween = getPaperLength() - (one.length + two.length)
        Log.d("TAg", "printTwoStringStringData: $spaceInBetween")
        str.append(one)
        for (i in 0..spaceInBetween) {
            str.append("  ")
        }
        str.append(two)
        return str.toString()
    }

    private fun printThreeStringData(one: String, two: String, three: String): String {
        val optionTextLength = ("Closing Balance ".length) - 5;//11===8
        val str = StringBuffer()
        val spaceInBetween =
            (getPaperLength() - (optionTextLength + two.length + three.length + 2)) / 2

        Log.d("TAg", "printThreeStringData: $spaceInBetween")
        var isEmptyStr = (one.replace(" ", "").length == 0)
        if (isEmptyStr) {
            str.append(one)
            for (i in one.length..(getPaperLength() / 2 + 1)) {
                str.append("  ")
            }

            for (i in 0..spaceInBetween) {
                str.append("  ")
            }
            str.append(two)
            for (i in 0..spaceInBetween) {
                str.append("  ")
            }
            str.append(three)

        } else {

            /*for(i in 0..optionTextLength){
                    str.append(one[i])
                }*/
            str.append(one)

            /*if(one.length <= optionTextLength){
                str.append(one)
                for(i in one.length..optionTextLength){
                    str.append("  ")
                }
            } else {

            }*/


            for (i in 0..(18 - (one.length + two.length))) {
                str.append("  ")
            }
            str.append(two)
            for (i in 0..(8 - three.length)) {
                str.append("  ")
            }
            str.append(three)
        }


        return str.toString()
    }


}

fun bitmapOverlayToCenter(bitmap1: Bitmap, overlayBitmap: Bitmap): Bitmap? {
    val bitmap1Width = bitmap1.width
    val bitmap1Height = bitmap1.height
    val bitmap2Width = overlayBitmap.width
    val bitmap2Height = overlayBitmap.height
    val marginLeft = (bitmap1Width*2 + bitmap2Width*2).toFloat()
    val marginTop = (bitmap1Height * 0.5 - bitmap2Height * 0.5).toFloat()
    val finalBitmap = Bitmap.createBitmap(bitmap1Width, bitmap1Height, bitmap1.config)
    val canvas = Canvas(finalBitmap)
    canvas.drawBitmap(bitmap1, Matrix(), null)
    canvas.drawBitmap(overlayBitmap, marginLeft, marginTop, null)
    return finalBitmap
}

//temp code
/*
* package com.skilrock.wls_pos

import InvFlowResponseData
import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.Drawable
import android.os.Build
import android.util.Log
import android.widget.Toast
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.common.apiutil.CommonException
import com.common.apiutil.TimeoutException
import com.common.apiutil.printer.*
import com.common.apiutil.printer.ThermalPrinter.stop
import com.google.gson.Gson
import com.sunmi.peripheral.printer.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*
import android.view.WindowManager.LayoutParams
class MainActivity: FlutterActivity() {
    private val mChannel = "com.skilrock.wls_pos/test"
    private lateinit var channel_print: MethodChannel
    private val mChannelForPrint = "com.skilrock.longalottoretail/notification_print"

    private val boldFontEnable = byteArrayOf(0x1B, 0x45, 0x1)
    private val boldFontDisable = byteArrayOf(0x1B, 0x45, 0x0)
    private lateinit var channel: MethodChannel
    private var mSunmiPrinterService: SunmiPrinterService? = null


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        window.addFlags(LayoutParams.FLAG_SECURE)
        getWindow().setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE);
        super.configureFlutterEngine(flutterEngine)
        initializeSunmiPrinter()

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mChannel)

        channel.setMethodCallHandler { call, result ->
            val argument = call.arguments as Map<*, *>

            if (call.method == "invFlowPrint") {
                val invFlowResponse = argument["invFlowResponse"]
                val startDate = argument["startDate"]
                val endDate = argument["endDate"]
                val userName = argument["name"]
                val showGameWiseOpeningBalanceData: Boolean =
                    argument["showGameWiseOpeningBalanceData"].toString().toBoolean()
                val showGameWiseClosingBalanceData: Boolean =
                    argument["showGameWiseClosingBalanceData"].toString().toBoolean()
                val showReceivedData: Boolean = argument["showReceivedData"].toString().toBoolean()
                val showReturnedData: Boolean = argument["showReturnedData"].toString().toBoolean()
                val showSoldData: Boolean = argument["showSoldData"].toString().toBoolean()
                val bookTicketLength = 8
                println("showGameWiseOpeningBalanceData: $showGameWiseOpeningBalanceData")
                println("showGameWiseOpeningBalanceData:type: ${showGameWiseOpeningBalanceData::class.java}")

                val invFlowResponseData =
                    Gson().fromJson(invFlowResponse.toString(), InvFlowResponseData::class.java)
                mSunmiPrinterService?.run {
                    enterPrinterBuffer(true)
                    setAlignment(1, null)
                    sendRAWData(boldFontEnable, null)
                    setFontSize(25f, null)
                    printText("Inventory Flow Report", null)
                    setFontSize(21f, null)
                    printText("\nDate $startDate To $endDate", null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n____________________________\n", null)
                    printText("Organization name : $userName", null)
                    printText("\n____________________________\n", null)

                    sendRAWData(boldFontEnable, null)
                    printColumnsString(
                        arrayOf<String>(
                            "", "Books ", "Tickets"
                        ),
                        intArrayOf(
                            bookTicketLength, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 2, 2),
                        null
                    )
                    sendRAWData(boldFontDisable, null)

                    printColumnsString(
                        arrayOf<String>(
                            "OpenBalance ",
                            "${invFlowResponseData.booksOpeningBalance} ",
                            "${invFlowResponseData.ticketsOpeningBalance}"
                        ),
                        intArrayOf(
                            "OpenBalance ".length, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 2, 2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            "Received ",
                            "${invFlowResponseData.receivedBooks} ",
                            "${invFlowResponseData.receivedTickets}"
                        ),
                        intArrayOf(
                            "Received ".length, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 2, 2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            "Returned ",
                            "${invFlowResponseData.returnedBooks} ",
                            "${invFlowResponseData.returnedTickets}"
                        ),
                        intArrayOf(
                            "Returned ".length, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 2, 2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            "Sales ",
                            "${invFlowResponseData.soldBooks} ",
                            "${invFlowResponseData.soldTickets}"
                        ),
                        intArrayOf(
                            "Sales ".length, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 2, 2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            "Closing Balance ",
                            "${invFlowResponseData.booksClosingBalance} ",
                            "${invFlowResponseData.ticketsClosingBalance}"
                        ),
                        intArrayOf(
                            "Closing Balance ".length, bookTicketLength, bookTicketLength
                        ),
                        intArrayOf(0, 2, 2),
                        null
                    )

                    printText("\n", null)

                    if (showGameWiseOpeningBalanceData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Open Balance ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                "Open Balance ".length, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 2, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)

                        for (gameWiseOpeningData in invFlowResponseData.gameWiseOpeningBalanceData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseOpeningData.gameName + " ",
                                    "${gameWiseOpeningData.totalBooks} ",
                                    "${gameWiseOpeningData.totalTickets}"
                                ),
                                intArrayOf(
                                    gameWiseOpeningData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 2, 2),
                                null
                            )
                        }
                    }
                    printText("\n", null)

                    if (showReceivedData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Received ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                "Received ".length, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 2, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)
                        for (gameWiseData in invFlowResponseData.gameWiseData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseData.gameName + " ",
                                    "${gameWiseData.receivedBooks} ",
                                    "${gameWiseData.receivedTickets}"
                                ),
                                intArrayOf(
                                    gameWiseData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 2, 2),
                                null
                            )
                        }
                    }
                    printText("\n", null)

                    if (showReturnedData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Returned ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                "Returned ".length, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 2, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)
                        for (gameWiseData in invFlowResponseData.gameWiseData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseData.gameName + " ",
                                    "${gameWiseData.returnedBooks} ",
                                    "${gameWiseData.returnedTickets}"
                                ),
                                intArrayOf(
                                    gameWiseData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 2, 2),
                                null
                            )
                        }
                    }
                    printText("\n", null)

                    if (showSoldData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Sale ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                "Sale ".length, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 2, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)
                        for (gameWiseData in invFlowResponseData.gameWiseData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseData.gameName + " ",
                                    "${gameWiseData.soldBooks} ",
                                    "${gameWiseData.soldTickets}"
                                ),
                                intArrayOf(
                                    gameWiseData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 2, 2),
                                null
                            )
                        }
                    }
                    printText("\n", null)

                    if (showGameWiseClosingBalanceData) {
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Closing Balance ", "Books ", "Tickets"
                            ),
                            intArrayOf(
                                "Closing Balance ".length, bookTicketLength, bookTicketLength
                            ),
                            intArrayOf(0, 2, 2),
                            null
                        )
                        sendRAWData(boldFontDisable, null)

                        for (gameWiseClosingData in invFlowResponseData.gameWiseClosingBalanceData) {
                            printColumnsString(
                                arrayOf<String>(
                                    gameWiseClosingData.gameName + " ",
                                    "${gameWiseClosingData.totalBooks} ",
                                    "${gameWiseClosingData.totalTickets}"
                                ),
                                intArrayOf(
                                    gameWiseClosingData.gameName.length + 1,
                                    bookTicketLength,
                                    bookTicketLength
                                ),
                                intArrayOf(0, 2, 2),
                                null
                            )
                        }
                    }
                    printText("\n------ FOR DEMO ------\n\n", null)
                    exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                        override fun onRunResult(isSuccess: Boolean) {}

                        override fun onReturnString(result: String?) {}

                        override fun onRaiseException(code: Int, msg: String?) {
                            activity.runOnUiThread {
                                Toast.makeText(
                                    activity,
                                    "Something went wrong while printing, Please try again",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                            result.error("-1", msg, "Something went wrong while printing")
                        }

                        override fun onPrintResult(code: Int, msg: String?) {
                            if (updatePrinterState() != 1) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")

                            } else {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)
                            }
                        }
                    })

                } ?: this.let {
                    val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                    if (getDeviceName() == "QUALCOMM M1") {
                        usbThermalPrinter.run {
                            try {
                                reset()
                                start(1)
                                setTextSize(25)
                                addString("")
                                setBold(true)
                                setGray(1)
                                setAlgin(1)
                                addString("Inventory Flow Report")
                                setTextSize(21)
                                setBold(false)
                                addString("Date $startDate To $endDate")
                                setBold(false)
                                addString(printLineStringData(getPaperLength()))
                                addString("Organization name : $userName")
                                addString(printLineStringData(getPaperLength()))
                                addString("\n")
                                setBold(true)
                                addString(printThreeStringData("        ", "Books", "Tickets"))
                                setBold(false)
                                addString(
                                    printThreeStringData(
                                        "OpenBalance",
                                        "${invFlowResponseData.booksOpeningBalance}",
                                        "${invFlowResponseData.ticketsOpeningBalance}"
                                    )
                                )
                                addString(
                                    printThreeStringData(
                                        "Received",
                                        "${invFlowResponseData.receivedBooks}",
                                        "${invFlowResponseData.receivedTickets}"
                                    )
                                )
                                addString(
                                    printThreeStringData(
                                        "Returned",
                                        "${invFlowResponseData.returnedBooks}",
                                        "${invFlowResponseData.returnedTickets}"
                                    )
                                )
                                addString(
                                    printThreeStringData(
                                        "Sales",
                                        "${invFlowResponseData.soldBooks}",
                                        "${invFlowResponseData.soldTickets}"
                                    )
                                )
                                addString(
                                    printThreeStringData(
                                        "Closing Balance",
                                        "${invFlowResponseData.booksClosingBalance}",
                                        "${invFlowResponseData.ticketsClosingBalance}"
                                    )
                                )
                                if (showGameWiseOpeningBalanceData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(
                                        printThreeStringData(
                                            "Open Balance ",
                                            "Books ",
                                            "Tickets"
                                        )
                                    )
                                    setBold(false)
                                    for (gameWiseOpeningData in invFlowResponseData.gameWiseOpeningBalanceData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseOpeningData.gameName,
                                                "${gameWiseOpeningData.totalBooks}",
                                                "${gameWiseOpeningData.totalTickets}"
                                            )
                                        )
                                    }
                                }
                                if (showReceivedData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(
                                        printThreeStringData(
                                            "Received ",
                                            "Books ",
                                            "Tickets"
                                        )
                                    )
                                    setBold(false)
                                    for (gameWiseData in invFlowResponseData.gameWiseData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseData.gameName,
                                                "${gameWiseData.receivedBooks} ",
                                                "${gameWiseData.receivedTickets}"
                                            )
                                        )
                                    }
                                }
                                if (showReturnedData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(
                                        printThreeStringData(
                                            "Returned ",
                                            "Books ",
                                            "Tickets"
                                        )
                                    )
                                    setBold(false)
                                    for (gameWiseData in invFlowResponseData.gameWiseData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseData.gameName,
                                                "${gameWiseData.returnedBooks} ",
                                                "${gameWiseData.returnedTickets}"
                                            )
                                        )
                                    }
                                }
                                if (showSoldData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(printThreeStringData("Sale ", "Books ", "Tickets"))
                                    setBold(false)
                                    for (gameWiseData in invFlowResponseData.gameWiseData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseData.gameName,
                                                "${gameWiseData.soldBooks} ",
                                                "${gameWiseData.soldTickets}"
                                            )
                                        )
                                    }
                                }
                                if (showGameWiseClosingBalanceData) {
                                    addString("\n")
                                    setBold(true)
                                    addString(
                                        printThreeStringData(
                                            "Closing Balance ",
                                            "Books ",
                                            "Tickets"
                                        )
                                    )
                                    setBold(false)
                                    for (gameWiseClosingData in invFlowResponseData.gameWiseClosingBalanceData) {
                                        addString(
                                            printThreeStringData(
                                                gameWiseClosingData.gameName,
                                                "${gameWiseClosingData.totalBooks} ",
                                                "${gameWiseClosingData.totalTickets}"
                                            )
                                        )
                                    }
                                }
                                addString("\n")
                                addString("----- FOR DEMO -----")
                                addString("\n")
                                printString()
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)
                            } catch (e: java.lang.Exception) {
                                showMsgAccordingToException(e as CommonException, result)
                                stop()
                                e.printStackTrace()
                            }
                        }

                    } else {
                        android.util.Log.d("TAg", "configureFlutterEngine: -----------")
                        result.error(
                            "-1",
                            "Unable to find printer",
                            "no sunmi or no usb thermal printer"
                        )
                    }
                }
            }
            //sports pool print
            else if (call.method == "sports_buy"){
                val currencyCode = argument["currencyCode"]
                val username = argument["username"]
                val saleResponse = argument["saleResponse"]
                val saleResponseData =
                    Gson().fromJson(saleResponse.toString(), SportsPoolSaleResponse::class.java)
                val qrCodeHelperObject = QRBarcodeHelper(activity.baseContext)
                qrCodeHelperObject.setContent(saleResponseData.responseData.ticketNumber)
                val bitmap =
                    BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)

                mSunmiPrinterService?.run {
                    enterPrinterBuffer(true)
                    setAlignment(1, null)
                    printBitmapCustom(resizedBitmap, 1, null)
                    sendRAWData(boldFontEnable, null)
                    setFontSize(24f, null)
                    printText("\n\n${saleResponseData.responseData.gameCode}", null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n${saleResponseData.responseData.ticketNumber}\n", null)
                    printColumnsString(
                        arrayOf<String>(
                            "Draw Time",
                            "Draw No.",
                        ),
                        intArrayOf(
                            "Draw Time".length, "Draw No.".length
                        ),
                        intArrayOf(0,2),
                        null
                    )
                    printColumnsString(
                        arrayOf<String>(
                            saleResponseData.responseData.drawDateTime,
                            "${saleResponseData.responseData.drawNo}",
                        ),
                        intArrayOf(
                            saleResponseData.responseData.drawDateTime.length, "${saleResponseData.responseData.drawNo}".length
                        ),
                        intArrayOf(0,2),
                        null
                    )
                    sendRAWData(boldFontEnable, null)
                    setFontSize(24f, null)
                    printText("\n\nDraw Result", null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n\nResult Will be declared on", null)
                    printText("\n${saleResponseData.responseData.drawDateTime}\n\n", null)
                    printColumnsString(
                        arrayOf<String>(
                            "Your Total Bet",
                            "$currencyCode ",
                            "${saleResponseData.responseData.totalSaleAmount}",
                        ),
                        intArrayOf(
                            "Your Total Bet".length, "$currencyCode ".length, "${saleResponseData.responseData.totalSaleAmount}".length
                        ),
                        intArrayOf(0,2,2),
                        null
                    )
                    //setFontSize(20f, null)
                    for (i in 0 until saleResponseData.responseData.mainDrawData.boards.size) {
                        printText("\n${saleResponseData.responseData.mainDrawData.boards[i].marketName}\n", null)
                        for (j in 0 until saleResponseData.responseData.mainDrawData.boards[i].events.size) {
                            printColumnsString(
                                arrayOf<String>(
                                    saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName,
                                    getSelectedOptions( saleResponseData.responseData.mainDrawData.boards[i].events[j].options)
                                ),
                                intArrayOf(
                                    saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName.length,  getSelectedOptions( saleResponseData.responseData.mainDrawData.boards[i].events[j].options).length
                                ),
                                intArrayOf(0,2),
                                null
                            )
                        }
                        printText("\n____________________________\n", null)
                    }
                    if(saleResponseData.responseData.addOnDrawData != null){
                        for (i in 0 until saleResponseData.responseData.addOnDrawData.boards.size) {
                            printText("\n${saleResponseData.responseData.addOnDrawData.boards[i].marketName}\n", null)
                            for (j in 0 until saleResponseData.responseData.addOnDrawData.boards[i].events.size) {
                                printColumnsString(
                                    arrayOf<String>(
                                        saleResponseData.responseData.addOnDrawData.boards[i].events[j].eventName,
                                        getSelectedOptionsAddOn( saleResponseData.responseData.addOnDrawData.boards[i].events[j].options)
                                    ),
                                    intArrayOf(
                                        saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName.length,  getSelectedOptionsAddOn( saleResponseData.responseData.addOnDrawData.boards[i].events[j].options).length
                                    ),
                                    intArrayOf(0,2),
                                    null
                                )
                            }
                            printText("\n____________________________\n", null)
                        }
                    }
                    printText("\n", null)
                    printBitmapCustom(qrCodeHelperObject.qrcOde, 1, null)
                    sendRAWData(boldFontDisable, null)
                    printText("\n${saleResponseData.responseData.ticketNumber}", null)
                    printText("\n\n$username", null)
                    // setFontSize(24f, null)
                    printText("\n------ FOR DEMO ------\n\n\n", null)
                    exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                        override fun onRunResult(isSuccess: Boolean) {}

                        override fun onReturnString(result: String?) {}

                        override fun onRaiseException(code: Int, msg: String?) {
                            activity.runOnUiThread {
                                Toast.makeText(
                                    activity,
                                    "Something went wrong while printing, Please try again",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                            result.error("-1", msg, "Something went wrong while printing")
                        }

                        override fun onPrintResult(code: Int, msg: String?) {
                            if (updatePrinterState() != 1) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")

                            } else {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)
                            }
                        }
                    })
                } ?: this.let {
                    val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                    if (getDeviceName() == "QUALCOMM M1") {
                        usbThermalPrinter.run {
                            try {
                                reset()
                                start(1)
                                setTextSize(28)
                                addString("")
                                setBold(true)
                                setGray(1)
                                setAlgin(1)
                                printLogo(resizedBitmap, true)
                                addString(saleResponseData.responseData.gameCode)
                                setTextSize(22)
                                setItalic(true)
                                setBold(false)
                                addString(saleResponseData.responseData.ticketNumber)
                                setItalic(false)
                                setBold(true)
                                setTextSize(24)
                                addString(
                                    printTwoStringStringData(
                                        "Draw Time",
                                        "Draw No."
                                    )
                                )
                                setBold(false)
                                addString(
                                    printTwoStringStringData(
                                        saleResponseData.responseData.drawDateTime,
                                        "${saleResponseData.responseData.drawNo}",
                                    )
                                )
                                //addString(printLineStringData(getPaperLength()))
                                setTextSize(22)
                                addString("Draw Result")
                                addString("Result will be declared on")
                                addString(saleResponseData.responseData.drawDateTime)
                                setTextSize(24)
                                addString(
                                    printTwoStringStringData(
                                        "Your Total Bet",
                                        "$currencyCode ${saleResponseData.responseData.totalSaleAmount}",
                                    )
                                )
                                //setTextSize(20)
                                for (i in 0 until saleResponseData.responseData.mainDrawData.boards.size) {
                                    setAlgin(1)
                                    addString("\n${saleResponseData.responseData.mainDrawData.boards[i].marketName}\n")
                                    for (j in 0 until saleResponseData.responseData.mainDrawData.boards[i].events.size) {
                                        addString(
                                            printTwoStringStringData(
                                                saleResponseData.responseData.mainDrawData.boards[i].events[j].eventName,
                                                getSelectedOptions( saleResponseData.responseData.mainDrawData.boards[i].events[j].options),
                                            )
                                        )
                                    }
                                    addString(printLineStringData(getPaperLength()))
                                }
                                Log.d("TAg", "saleResponseData.responseData.addOnDrawData: ${saleResponseData.responseData.addOnDrawData}")
                                if(saleResponseData.responseData.addOnDrawData != null){
                                    for (i in 0 until saleResponseData.responseData.addOnDrawData.boards.size) {
                                        addString("\n${saleResponseData.responseData.addOnDrawData.boards[i].marketName}\n")
                                        for (j in 0 until saleResponseData.responseData.addOnDrawData.boards[i].events.size) {
                                            addString(
                                                printTwoStringStringData(
                                                    saleResponseData.responseData.addOnDrawData.boards[i].events[j].eventName,
                                                    getSelectedOptionsAddOn( saleResponseData.responseData.addOnDrawData.boards[i].events[j].options),
                                                )
                                            )
                                        }
                                        addString(printLineStringData(getPaperLength()))
                                    }
                                }
                                addString("\n")
                                printLogo(qrCodeHelperObject.qrcOde, true)
                                addString(saleResponseData.responseData.ticketNumber)
                                addString("\n")
                                addString("$username")
                                addString("\n")
                                addString("----- FOR DEMO -----")
                                addString("\n")
                                addString("\n")
                                addString("\n")
                                printString()
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)

                            } catch (e: java.lang.Exception) {
                                showMsgAccordingToException(e as CommonException, result)
                                stop()
                                e.printStackTrace()
                            }
                        }

                    } else {
                        result.error(
                            "-1",
                            "Unable to find printer",
                            "no sunmi or no usb thermal printer"
                        )
                    }
                }
            }

            // else part
            else {
                val currencyCode = argument["currencyCode"]
                val username = argument["username"]
                val saleResponse = argument["saleResponse"]
                val panelArgData = argument["panelData"]
                val cancelTicketResponse = argument["cancelTicketResponse"]
                val rePrintResponse = argument["rePrint"]
                val resultDataResponse = argument["resultData"]
                val winClaimedResponse = argument["winClaimedResponse"]

                val saleResponseData =
                    Gson().fromJson(saleResponse.toString(), SaleResponseData::class.java)
                val panelData = Gson().fromJson(panelArgData.toString(), PanelData::class.java)

                val cancelTicketResponseData = Gson().fromJson(
                    cancelTicketResponse.toString(),
                    CancelTicketResponseData::class.java
                )
                val resultResponseData =
                    Gson().fromJson(resultDataResponse.toString(), ResultData::class.java)
                val winClaimedResponseData =
                    Gson().fromJson(winClaimedResponse.toString(), WinClaimedResponse::class.java)
                if (call.method == "buy") {
                    val qrCodeHelperObject = QRBarcodeHelper(activity.baseContext)
                    qrCodeHelperObject.setContent(saleResponseData.responseData.ticketNumber)
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)

                    mSunmiPrinterService?.run {

                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${saleResponseData.responseData.gameName}", null)
                        sendRAWData(boldFontDisable, null)
                        printText("\nPurchase Time", null)
                        val purchaseDate: String =
                            saleResponseData.responseData.purchaseTime.split(" ")[0]
                        val purchaseTime: String =
                            saleResponseData.responseData.purchaseTime.split(" ")[1]
                        printText(
                            "\n${getFormattedDate(purchaseDate)} ${
                                getFormattedTime(
                                    purchaseTime
                                )
                            }", null
                        )
                        printText("\nTicket Number", null)
                        printText("\n${saleResponseData.responseData.ticketNumber}", null)
                        printText("\n____________________________", null)
                        printText("\nDraw Timing", null)
                        for (i in saleResponseData.responseData.drawData) {
                            printText("\n${getFormattedDate(i.drawDate)} ${i.drawTime}", null)
                        }
                        printText("\n____________________________", null)
                        printText("\nBet Details", null)
                        var amount = 0.0
                        var numberString: String
                        Log.i(
                            "TaG",
                            "---------------->${saleResponseData.responseData.panelData.size}"
                        )
                        if (saleResponseData.responseData.gameCode == "ThaiLottery") {
                            for (i in 0 until saleResponseData.responseData.panelData.size) {
                                if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Number",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText(
                                        "\n${saleResponseData.responseData.panelData[i].pickedValues}\n",
                                        null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            "${saleResponseData.responseData.panelData[i].pickDisplayName} : ${saleResponseData.responseData.panelData[i].betDisplayName}",
                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                        ),
                                        intArrayOf(
                                            "${saleResponseData.responseData.panelData[i].pickDisplayName} : ${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            "No of lines",
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                        ),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                }
                            }
                        } else {
                            for (i in 0 until panelData.size) {
                                val isQp =
                                    if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Number",
                                        ignoreCase = true
                                    )
                                ) {
                                    if (saleResponseData.responseData.panelData[i].pickType.equals(
                                            "Banker",
                                            ignoreCase = true
                                        )
                                    ) {
                                        numberString =
                                            saleResponseData.responseData.panelData[i].pickedValues
                                        val banker: Array<String> =
                                            numberString.split("-").toTypedArray()
                                        printText("\nUL - ${banker[0]}", null)
                                        printText("\nLL - ${banker[1]}\n", null)
                                        if (saleResponseData.responseData.panelData[i].quickPick) {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        } else {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        }
                                        printColumnsString(
                                            arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                            intArrayOf(
                                                "No of lines".length,
                                                "${panelData[i].numberOfLines}".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )

                                        printText("\n----------------------------", null)
                                        amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines

                                    } else {
                                        printText("\n${panelData[i].pickedValue}\n", null)
                                        if (saleResponseData.responseData.panelData[i].quickPick) {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        } else {
                                            printColumnsString(
                                                arrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                ),
                                                intArrayOf(
                                                    "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                                    "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                        }
                                        printColumnsString(
                                            arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                            intArrayOf(
                                                "No of lines".length,
                                                "${panelData[i].numberOfLines}".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                        printText("\n----------------------------", null)
                                        amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                    }

                                } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Market",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText(
                                        "\n${saleResponseData.responseData.panelData[i].betDisplayName}\n",
                                        null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            saleResponseData.responseData.panelData[i].pickDisplayName,
                                            "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                        ),
                                        intArrayOf(
                                            saleResponseData.responseData.panelData[i].pickDisplayName.length,
                                            "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printColumnsString(
                                        arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Label",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText("\n${panelData[i].pickedValue}\n", null)
                                    printColumnsString(
                                        arrayOf(
                                            "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                            "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                        ),
                                        intArrayOf(
                                            "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                            "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printColumnsString(
                                        arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                }
                            }
                        }
                        printText("\nAmount                  $amount", null)
                        printText(
                            "\nNo of Draws(s)              ${saleResponseData.responseData.drawData.size}",
                            null
                        )
                        sendRAWData(boldFontEnable, null)
                        printText(
                            "\nTOTAL AMOUNT         ${saleResponseData.responseData.totalPurchaseAmount} $currencyCode\n\n",
                            null
                        )
                        printBitmapCustom(qrCodeHelperObject.qrcOde, 1, null)
                        sendRAWData(boldFontDisable, null)
                        printText("\n${saleResponseData.responseData.ticketNumber}", null)
                        printText("\n\n$username", null)
                        printText(
                            "\nTicket Validity: ${saleResponseData.responseData.ticketExpiry}\n",
                            null
                        )
                        printText("\n------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(28)
                                    addString("")
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(saleResponseData.responseData.gameName)
                                    setTextSize(22)
                                    val purchaseDate: String =
                                        saleResponseData.responseData.purchaseTime.split(" ")[0]
                                    val purchaseTime: String =
                                        saleResponseData.responseData.purchaseTime.split(" ")[1]
                                    setItalic(true)
                                    setBold(false)
                                    addString("Purchase Time")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(
                                        "${getFormattedDate(purchaseDate)} ${
                                            getFormattedTime(
                                                purchaseTime
                                            )
                                        }"
                                    )
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Ticket Number")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(saleResponseData.responseData.ticketNumber)
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Draw Timing")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    for (i in saleResponseData.responseData.drawData) {
                                        addString("${getFormattedDate(i.drawDate)} ${i.drawTime}")

                                    }
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Bet Details")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    var amount = 0.0
                                    var numberString: String
                                    if (saleResponseData.responseData.gameCode == "ThaiLottery") {
                                        for (i in 0 until saleResponseData.responseData.panelData.size) {
                                            if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(saleResponseData.responseData.panelData[i].pickedValues)
                                                addString(
                                                    printTwoStringStringData(
                                                        "${saleResponseData.responseData.panelData[i].pickDisplayName} : ${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                        "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    )
                                                )
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != saleResponseData.responseData.panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                            }
                                        }
                                    } else {
                                        for (i in 0 until panelData.size) {
                                            val isQp =
                                                if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                            if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                if (saleResponseData.responseData.panelData[i].pickType.equals(
                                                        "Banker",
                                                        ignoreCase = true
                                                    )
                                                ) {
                                                    numberString =
                                                        saleResponseData.responseData.panelData[i].pickedValues
                                                    val banker: Array<String> =
                                                        numberString.split("-").toTypedArray()

                                                    addString("UL - ${banker[0]}")
                                                    addString("LL - ${banker[1]}")
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    addString(printDashStringData(getPaperLength()))
                                                    amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines

                                                } else {
                                                    addString(panelData[i].pickedValue)
                                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${panelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    if (i != panelData.size - 1) addString(
                                                        printDashStringData(getPaperLength())
                                                    )
                                                    amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                                }

                                            } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Market",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(saleResponseData.responseData.panelData[i].betDisplayName)
                                                addString(
                                                    printTwoStringStringData(
                                                        saleResponseData.responseData.panelData[i].pickDisplayName,
                                                        "${panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                    )
                                                )
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += panelData[i].unitPrice * panelData[i].betAmountMultiple * panelData[i].numberOfLines
                                            }
                                        }
                                    }
                                    setBold(true)
                                    addString(printLineStringData(getPaperLength()))
                                    setTextSize(24)
                                    addString(printTwoStringStringData("Amount", "$amount"))
                                    addString(
                                        printTwoStringStringData(
                                            "No of Draws(s)",
                                            "${saleResponseData.responseData.drawData.size}"
                                        )
                                    )
                                    addString(printDashStringData(getPaperLength()))
                                    addString(
                                        printTwoStringStringData(
                                            "TOTAL AMOUNT",
                                            "${saleResponseData.responseData.totalPurchaseAmount} $currencyCode"
                                        )
                                    )
                                    addString(" ")
                                    printLogo(qrCodeHelperObject.qrcOde, true)
                                    addString(saleResponseData.responseData.ticketNumber)
                                    addString(" ")
                                    addString("$username")
                                    addString("Ticket Validity: ${saleResponseData.responseData.ticketExpiry}")
                                    addString("\n")
                                    addString("----- FOR DEMO -----")
                                    addString("\n")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)

                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
                else if (call.method == "dgeCancelTicket") {
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)

                    mSunmiPrinterService?.run {

                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)// logo
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${cancelTicketResponseData.responseData.gameName}", null)
                        sendRAWData(boldFontDisable, null)
                        printText("\nTicket Number", null)
                        printText("\n${cancelTicketResponseData.responseData.ticketNo}", null)
                        printText("\n____________________________\n", null)
                        sendRAWData(boldFontEnable, null)
                        printText("Ticket Cancelled\n", null)
                        sendRAWData(boldFontDisable, null)
                        printColumnsString(
                            arrayOf<String>(
                                "Refund Amount :",
                                "${cancelTicketResponseData.responseData.refundAmount} ${currencyCode}"
                            ),
                            intArrayOf(
                                "Refund Amount :".length,
                                "${cancelTicketResponseData.responseData.refundAmount} ${currencyCode}".length
                            ),
                            intArrayOf(0, 2),
                            null
                        )
                        printText("\n\n$username", null)
                        printText("\n------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(28)
                                    addString("")
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(cancelTicketResponseData.responseData.gameName)
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Ticket Number")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(cancelTicketResponseData.responseData.ticketNo)
                                    setBold(true)
                                    addString(printLineStringData(getPaperLength()))
                                    setTextSize(24)
                                    addString("Ticket Cancelled")
                                    setBold(false)
                                    addString(
                                        printTwoStringStringData(
                                            "Refund Amount :",
                                            "${cancelTicketResponseData.responseData.refundAmount} ${currencyCode}"
                                        )
                                    )
                                    addString("\n")
                                    addString("----- FOR DEMO -----")
                                    addString("\n")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)

                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
                else if (call.method == "dgeReprint") {
                    val qrCodeHelperObject = QRBarcodeHelper(activity.baseContext)
                    qrCodeHelperObject.setContent(saleResponseData.responseData.ticketNumber)
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)

                    mSunmiPrinterService?.run {

                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${saleResponseData.responseData.gameName}", null)
                        sendRAWData(boldFontDisable, null)
                        printText("\nPurchase Time", null)
                        val purchaseDate: String =
                            saleResponseData.responseData.purchaseTime.split(" ")[0]
                        val purchaseTime: String =
                            saleResponseData.responseData.purchaseTime.split(" ")[1]
                        printText(
                            "\n${getFormattedDate(purchaseDate)} ${
                                getFormattedTime(
                                    purchaseTime
                                )
                            }", null
                        )
                        printText("\nTicket Number", null)
                        printText("\n${saleResponseData.responseData.ticketNumber}", null)
                        printText("\n____________________________", null)
                        printText("\nDraw Timing", null)
                        for (i in saleResponseData.responseData.drawData) {
                            printText("\n${getFormattedDate(i.drawDate)} ${i.drawTime}", null)
                        }
                        printText("\n____________________________", null)
                        printText("\nBet Details", null)
                        var amount = 0.0
                        var numberString: String
                        for (i in 0 until panelData.size) {
                            val isQp =
                                if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                            if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                    "Number",
                                    ignoreCase = true
                                )
                            ) {
                                if (saleResponseData.responseData.panelData[i].pickType.equals(
                                        "Banker",
                                        ignoreCase = true
                                    )
                                ) {
                                    numberString =
                                        saleResponseData.responseData.panelData[i].pickedValues
                                    val banker: Array<String> =
                                        numberString.split("-").toTypedArray()
                                    printText("\nUL - ${banker[0]}", null)
                                    printText("\nLL - ${banker[1]}\n", null)
                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                        printColumnsString(
                                            arrayOf(
                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                            ),
                                            intArrayOf(
                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )

                                    } else {
                                        printColumnsString(
                                            arrayOf(
                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                            ),
                                            intArrayOf(
                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                    }
                                    printColumnsString(
                                        arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )

                                    printText("\n----------------------------", null)
                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines

                                } else {
                                    printText(
                                        "\n${saleResponseData.responseData.panelData[i].pickedValues}\n",
                                        null
                                    )
                                    if (saleResponseData.responseData.panelData[i].quickPick) {
                                        printColumnsString(
                                            arrayOf(
                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                            ),
                                            intArrayOf(
                                                "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )

                                    } else {
                                        printColumnsString(
                                            arrayOf(
                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                            ),
                                            intArrayOf(
                                                "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}".length,
                                                "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )

                                    }
                                    printColumnsString(
                                        arrayOf(
                                            "No of lines",
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                        ),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${saleResponseData.responseData.panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                }

                            } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                    "Market",
                                    ignoreCase = true
                                )
                            ) {
                                printText(
                                    "\n${saleResponseData.responseData.panelData[i].betDisplayName}\n",
                                    null
                                )
                                printColumnsString(
                                    arrayOf(
                                        saleResponseData.responseData.panelData[i].pickDisplayName,
                                        "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                    ),
                                    intArrayOf(
                                        saleResponseData.responseData.panelData[i].pickDisplayName.length,
                                        "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                    ),
                                    intArrayOf(0, 2), null
                                )
                                printColumnsString(
                                    arrayOf(
                                        "No of lines",
                                        "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                    ),
                                    intArrayOf(
                                        "No of lines".length,
                                        "${saleResponseData.responseData.panelData[i].numberOfLines}".length
                                    ),
                                    intArrayOf(0, 2), null
                                )
                                printText("\n----------------------------", null)
                                amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                            }
                        }
                        printText("\nAmount                  $amount", null)
                        printText(
                            "\nNo of Draws(s)              ${saleResponseData.responseData.drawData.size}",
                            null
                        )
                        sendRAWData(boldFontEnable, null)
                        printText(
                            "\nTOTAL AMOUNT         ${saleResponseData.responseData.totalPurchaseAmount} $currencyCode\n\n",
                            null
                        )
                        printBitmapCustom(qrCodeHelperObject.qrcOde, 1, null)
                        sendRAWData(boldFontDisable, null)
                        printText("\n${saleResponseData.responseData.ticketNumber}", null)
                        printText("\n\n$username", null)
                        printText(
                            "\nTicket Validity: ${saleResponseData.responseData.ticketExpiry}\n",
                            null
                        )
                        printText("\n------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(28)
                                    addString("")
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(saleResponseData.responseData.gameName)
                                    setTextSize(22)
                                    val purchaseDate: String =
                                        saleResponseData.responseData.purchaseTime.split(" ")[0]
                                    val purchaseTime: String =
                                        saleResponseData.responseData.purchaseTime.split(" ")[1]
                                    setItalic(true)
                                    setBold(false)
                                    addString("Purchase Time")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(
                                        "${getFormattedDate(purchaseDate)} ${
                                            getFormattedTime(
                                                purchaseTime
                                            )
                                        }"
                                    )
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Ticket Number")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    addString(saleResponseData.responseData.ticketNumber)
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Draw Timing")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    for (i in saleResponseData.responseData.drawData) {
                                        addString("${getFormattedDate(i.drawDate)} ${i.drawTime}")

                                    }
                                    setBold(false)
                                    addString(printLineStringData(getPaperLength()))
                                    setItalic(true)
                                    setTextSize(22)
                                    addString("Bet Details")
                                    setItalic(false)
                                    setBold(true)
                                    setTextSize(24)
                                    var amount = 0.0
                                    var numberString: String
                                    for (i in 0 until panelData.size) {
                                        val isQp =
                                            if (saleResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                        if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                "Number",
                                                ignoreCase = true
                                            )
                                        ) {
                                            if (saleResponseData.responseData.panelData[i].pickType.equals(
                                                    "Banker",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                numberString =
                                                    saleResponseData.responseData.panelData[i].pickedValues
                                                val banker: Array<String> =
                                                    numberString.split("-").toTypedArray()

                                                addString("UL - ${banker[0]}")
                                                addString("LL - ${banker[1]}")
                                                if (saleResponseData.responseData.panelData[i].quickPick) {
                                                    addString(
                                                        printTwoStringStringData(
                                                            "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                        )
                                                    )

                                                } else {
                                                    addString(
                                                        printTwoStringStringData(
                                                            "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                        )
                                                    )

                                                }
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                    )
                                                )
                                                addString(printDashStringData(getPaperLength()))
                                                amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines

                                            } else {
                                                addString(saleResponseData.responseData.panelData[i].pickedValues)
                                                if (saleResponseData.responseData.panelData[i].quickPick) {
                                                    addString(
                                                        printTwoStringStringData(
                                                            "${saleResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                        )
                                                    )

                                                } else {
                                                    addString(
                                                        printTwoStringStringData(
                                                            "${saleResponseData.responseData.panelData[i].pickDisplayName}/${saleResponseData.responseData.panelData[i].betDisplayName}",
                                                            "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                        )
                                                    )

                                                }
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != panelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                            }

                                        } else if (saleResponseData.responseData.panelData[i].pickConfig.equals(
                                                "Market",
                                                ignoreCase = true
                                            )
                                        ) {
                                            addString(saleResponseData.responseData.panelData[i].betDisplayName)
                                            addString(
                                                printTwoStringStringData(
                                                    saleResponseData.responseData.panelData[i].pickDisplayName,
                                                    "${saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                )
                                            )
                                            addString(
                                                printTwoStringStringData(
                                                    "No of lines",
                                                    "${saleResponseData.responseData.panelData[i].numberOfLines}"
                                                )
                                            )
                                            if (i != panelData.size - 1) addString(
                                                printDashStringData(getPaperLength())
                                            )
                                            amount += saleResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines
                                        }
                                    }
                                    setBold(true)
                                    addString(printLineStringData(getPaperLength()))
                                    setTextSize(24)
                                    addString(printTwoStringStringData("Amount", "$amount"))
                                    addString(
                                        printTwoStringStringData(
                                            "No of Draws(s)",
                                            "${saleResponseData.responseData.drawData.size}"
                                        )
                                    )
                                    addString(printDashStringData(getPaperLength()))
                                    addString(
                                        printTwoStringStringData(
                                            "TOTAL AMOUNT",
                                            "${saleResponseData.responseData.totalPurchaseAmount} $currencyCode"
                                        )
                                    )
                                    addString(" ")
                                    printLogo(qrCodeHelperObject.qrcOde, true)
                                    addString(saleResponseData.responseData.ticketNumber)
                                    addString(" ")
                                    addString("$username")
                                    addString("Ticket Validity: ${saleResponseData.responseData.ticketExpiry}")
                                    addString("\n")
                                    addString("----- FOR DEMO -----")
                                    addString("\n")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)

                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
                else if (call.method == "dgeLastResult") {
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)
                    Log.i("TaG", "resultResponseData------->${resultResponseData}")
                    mSunmiPrinterService?.run {

                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${resultResponseData.drawName}", null)
                        sendRAWData(boldFontDisable, null)
                        printText("\nDraw Time", null)
                        /*val purchaseDate: String = resultResponseData.drawTime.split(" ")[0]
                        val purchaseTime: String = resultResponseData.drawTime.split(" ")[1]*/
                        printText("\n${resultResponseData.drawTime}", null)
                        printText("\n____________________________", null)
                        printText("\nResult", null)
                        printText("\n${resultResponseData.winningNo}", null)
                        printText("\n____________________________", null)
                        if (resultResponseData?.sideBetMatchInfo != null && resultResponseData.sideBetMatchInfo.isNotEmpty()) {
                            printText("\nSide Bet\n", null)
                            var amount = 0.0
                            var numberString: String
                            for (i in 0 until resultResponseData.sideBetMatchInfo.size) {
                                printColumnsString(
                                    arrayOf<String>(
                                        "${resultResponseData.sideBetMatchInfo[i]?.betDisplayName}",
                                        "${resultResponseData.sideBetMatchInfo[i]?.pickTypeName}"
                                    ),
                                    intArrayOf(
                                        "${resultResponseData.sideBetMatchInfo[i]?.betDisplayName}".length,
                                        "${resultResponseData.sideBetMatchInfo[i]?.pickTypeName}".length
                                    ),
                                    intArrayOf(0, 2),
                                    null
                                )
                                printText("\n____________________________\n", null)
                            }
                        }

                        sendRAWData(boldFontEnable, null)

                        if (resultResponseData.winningMultiplierInfo != null) {
                            printColumnsString(
                                arrayOf<String>(
                                    "Winning Multiplier",
                                    "${resultResponseData.winningMultiplierInfo.multiplierCode} (${resultResponseData.winningMultiplierInfo?.value})"
                                ),
                                intArrayOf(
                                    "Winning Multiplier".length,
                                    "${resultResponseData.winningMultiplierInfo.multiplierCode} (${resultResponseData.winningMultiplierInfo?.value})".length
                                ),
                                intArrayOf(0, 2),
                                null
                            )
                        }

                        sendRAWData(boldFontDisable, null)
                        printText("\n------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        if (getDeviceName() == "QUALCOMM M1") {
                            val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                            usbThermalPrinter.run {
                                try {
                                    reset()
                                    start(1)
                                    setTextSize(28)
                                    addString("")
                                    setBold(true)
                                    setGray(1)
                                    setAlgin(1)
                                    printLogo(resizedBitmap, true)
                                    addString(resultResponseData.drawName)
                                    setTextSize(22)
                                    addString(printDashStringData(getPaperLength()))
                                    addString("Draw Time")
                                    addString(resultResponseData.drawTime)
                                    addString(printDashStringData(getPaperLength()))
                                    addString("Result")
                                    addString("${resultResponseData.winningNo}")
                                    addString(printDashStringData(getPaperLength()))
                                    if (resultResponseData?.sideBetMatchInfo != null && resultResponseData.sideBetMatchInfo.isNotEmpty()) {
                                        addString("Side Bet")
                                        var amount = 0.0
                                        var numberString: String
                                        for (i in 0 until resultResponseData.sideBetMatchInfo.size) {
                                            addString(
                                                printTwoStringStringData(
                                                    "${resultResponseData.sideBetMatchInfo[i]?.betDisplayName}",
                                                    "${resultResponseData.sideBetMatchInfo[i]?.pickTypeName}"
                                                )
                                            )
                                            addString(printDashStringData(getPaperLength()))
                                        }
                                    }

                                    /*val purchaseDate: String = resultResponseData.drawTime.split(" ")[0]
                                    val purchaseTime: String = resultResponseData.drawTime.split(" ")[1]*/
                                    addString(printDashStringData(getPaperLength()))
                                    resultResponseData.winningMultiplierInfo?.let {
                                        addString(
                                            printTwoStringStringData(
                                                "Winning Multiplier",
                                                "${resultResponseData.winningMultiplierInfo.multiplierCode} (${resultResponseData.winningMultiplierInfo.value})"
                                            )
                                        )
                                        addString(printDashStringData(getPaperLength()))
                                        addString("\n")
                                    }
                                    addString("\n")
                                    addString("----- FOR DEMO -----")
                                    addString("\n")
                                    printString()
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }

                    }
                }
                else if (call.method == "winClaim") {
                    val qrCodeHelperObject = QRBarcodeHelper(activity.baseContext)
                    qrCodeHelperObject.setContent(winClaimedResponseData.responseData.ticketNumber)
                    val bitmap =
                        BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
                    val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 150, false)

                    mSunmiPrinterService?.run {

                        enterPrinterBuffer(true)
                        setAlignment(1, null)
                        printBitmapCustom(resizedBitmap, 1, null)
                        sendRAWData(boldFontEnable, null)
                        setFontSize(24f, null)
                        printText("\n\n${winClaimedResponseData.responseData.gameName}", null)
                        printText("\n____________________________\n\n", null)
                        sendRAWData(boldFontDisable, null)
                        for (i in winClaimedResponseData.responseData.drawData) {
                            printColumnsString(
                                arrayOf("Draw Date", getFormattedDateForWinClaim(i.drawDate)),
                                intArrayOf(
                                    "Draw Date".length,
                                    getFormattedDateForWinClaim(i.drawDate).length
                                ),
                                intArrayOf(0, 2), null
                            )
                            printColumnsString(
                                arrayOf("Draw Time", i.drawTime),
                                intArrayOf("Draw Time".length, i.drawTime.length),
                                intArrayOf(0, 2), null
                            )
                            printColumnsString(
                                arrayOf("Win Status", i.winStatus),
                                intArrayOf("Win Status".length, i.winStatus.length),
                                intArrayOf(0, 2), null
                            )
                            printColumnsString(
                                arrayOf("Winning Amount", "${i.winningAmount} ${currencyCode}"),
                                intArrayOf(
                                    "Winning Amount".length,
                                    "${i.winningAmount} ${currencyCode}".length
                                ),
                                intArrayOf(0, 2), null
                            )
                            printText("____________________________\n\n", null)
                        }
                        sendRAWData(boldFontEnable, null)
                        printText("Reprint Ticket\n__________________\n", null)
                        sendRAWData(boldFontDisable, null)
                        var amount = 0.0
                        var numberString: String
                        if (winClaimedResponseData.responseData.gameCode == "ThaiLottery") {
                            for (i in 0 until winClaimedResponseData.responseData.panelData.size) {
                                if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                        "Number",
                                        ignoreCase = true
                                    )
                                ) {
                                    printText(
                                        "\n${winClaimedResponseData.responseData.panelData[i].pickedValues}\n",
                                        null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            "${winClaimedResponseData.responseData.panelData[i].pickDisplayName} : ${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                            "${winClaimedResponseData.responseData.panelData[i].unitCost * saleResponseData.responseData.panelData[i].betAmountMultiple * saleResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                        ),
                                        intArrayOf(
                                            "${winClaimedResponseData.responseData.panelData[i].pickDisplayName} : ${winClaimedResponseData.responseData.panelData[i].betDisplayName}".length,
                                            "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printColumnsString(
                                        arrayOf(
                                            "No of lines",
                                            "${winClaimedResponseData.responseData.panelData[i].numberOfLines}"
                                        ),
                                        intArrayOf(
                                            "No of lines".length,
                                            "${winClaimedResponseData.responseData.panelData[i].numberOfLines}".length
                                        ),
                                        intArrayOf(0, 2), null
                                    )
                                    printText("\n----------------------------", null)
                                    amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines
                                }
                            }
                        } else {
                            val panelDataList = winClaimedResponseData.responseData.panelData;
                            panelDataList.let { mPanelData ->
                                for (i in 0 until mPanelData.size) {
                                    val isQp =
                                        if (winClaimedResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                    if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                            "Number",
                                            ignoreCase = true
                                        )
                                    ) {
                                        if (winClaimedResponseData.responseData.panelData[i].pickType.equals(
                                                "Banker",
                                                ignoreCase = true
                                            )
                                        ) {
                                            numberString =
                                                winClaimedResponseData.responseData.panelData[i].pickedValues
                                            val banker: Array<String> =
                                                numberString.split("-").toTypedArray()
                                            printText("\nUL - ${banker[0]}", null)
                                            printText("\nLL - ${banker[1]}\n", null)
                                            if (winClaimedResponseData.responseData.panelData[i].quickPick) {
                                                printColumnsString(
                                                    arrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                    ),
                                                    intArrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                    ),
                                                    intArrayOf(0, 2), null
                                                )

                                            } else {
                                                printColumnsString(
                                                    arrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                    ),
                                                    intArrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}".length,
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                    ),
                                                    intArrayOf(0, 2), null
                                                )

                                            }
                                            printColumnsString(
                                                arrayOf(
                                                    "No of lines",
                                                    "${winClaimedResponseData.responseData.panelData[i].numberOfLines}"
                                                ),
                                                intArrayOf(
                                                    "No of lines".length,
                                                    "${winClaimedResponseData.responseData.panelData[i].numberOfLines}".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )

                                            printText("\n----------------------------", null)
                                            amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines

                                        } else {
                                            printText(
                                                "\n${winClaimedResponseData.responseData.panelData[i].pickedValues}\n",
                                                null
                                            )
                                            if (winClaimedResponseData.responseData.panelData[i].quickPick) {
                                                printColumnsString(
                                                    arrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                                    ),
                                                    intArrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp".length,
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                                    ),
                                                    intArrayOf(0, 2), null
                                                )

                                            } else {
                                                printColumnsString(
                                                    arrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                    ),
                                                    intArrayOf(
                                                        "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}".length,
                                                        "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode".length
                                                    ),
                                                    intArrayOf(0, 2), null
                                                )

                                            }
                                            printColumnsString(
                                                arrayOf(
                                                    "No of lines",
                                                    "${winClaimedResponseData.responseData.panelData[i].numberOfLines}"
                                                ),
                                                intArrayOf(
                                                    "No of lines".length,
                                                    "${winClaimedResponseData.responseData.panelData[i].numberOfLines}".length
                                                ),
                                                intArrayOf(0, 2), null
                                            )
                                            printText("\n----------------------------", null)
                                            amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines
                                        }

                                    } else if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                            "Market",
                                            ignoreCase = true
                                        )
                                    ) {
                                        printText(
                                            "\n${winClaimedResponseData.responseData.panelData[i].betDisplayName}\n",
                                            null
                                        )
                                        printColumnsString(
                                            arrayOf(
                                                winClaimedResponseData.responseData.panelData[i].pickDisplayName,
                                                "${winClaimedResponseData.responseData.panelData[i].unitCost * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode"
                                            ),
                                            intArrayOf(
                                                winClaimedResponseData.responseData.panelData[i].pickDisplayName.length,
                                                "${winClaimedResponseData.responseData.panelData[i].unitCost * panelData[i].betAmountMultiple * panelData[i].numberOfLines} $currencyCode".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                        printColumnsString(
                                            arrayOf("No of lines", "${panelData[i].numberOfLines}"),
                                            intArrayOf(
                                                "No of lines".length,
                                                "${panelData[i].numberOfLines}".length
                                            ),
                                            intArrayOf(0, 2), null
                                        )
                                        printText("\n----------------------------", null)
                                        amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines
                                    }
                                }
                            }
                        }

                        Log.i(
                            "TaG",
                            "---------------->${winClaimedResponseData.responseData.panelData.size}"
                        )
                        setAlignment(0, null)
                        printText("\n", null)
                        printColumnsString(
                            arrayOf("Amount", "$amount"),
                            intArrayOf("Amount".length, "$amount".length),
                            intArrayOf(0, 2), null
                        )
                        printColumnsString(
                            arrayOf(
                                "No of Draws(s)",
                                "${winClaimedResponseData.responseData.drawData.size}"
                            ),
                            intArrayOf(
                                "No of Draws(s)".length,
                                "${winClaimedResponseData.responseData.drawData.size}".length
                            ),
                            intArrayOf(0, 2), null
                        )
                        sendRAWData(boldFontEnable, null)
                        printColumnsString(
                            arrayOf(
                                "TOTAL AMOUNT",
                                "${winClaimedResponseData.responseData.totalPurchaseAmount} $currencyCode"
                            ),
                            intArrayOf(
                                "TOTAL AMOUNT".length,
                                "${winClaimedResponseData.responseData.totalPurchaseAmount} $currencyCode".length
                            ),
                            intArrayOf(0, 2), null
                        )
                        printText("\n", null)
                        setAlignment(1, null)
                        printBitmapCustom(qrCodeHelperObject.qrcOde, 1, null)
                        sendRAWData(boldFontDisable, null)
                        printText("\n${winClaimedResponseData.responseData.ticketNumber}", null)
                        printText("\n$username\n", null)
                        printText("------ FOR DEMO ------\n\n", null)
                        exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                            override fun onRunResult(isSuccess: Boolean) {}

                            override fun onReturnString(result: String?) {}

                            override fun onRaiseException(code: Int, msg: String?) {
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Something went wrong while printing, Please try again",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.error("-1", msg, "Something went wrong while printing")
                            }

                            override fun onPrintResult(code: Int, msg: String?) {
                                if (updatePrinterState() != 1) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")

                                } else {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Successfully printed",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.success(true)
                                }
                            }
                        })
                    } ?: this.let {
                        val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                        if (getDeviceName() == "QUALCOMM M1") {
                            usbThermalPrinter.run {
                                reset()
                                start(1)
                                setTextSize(28)
                                addString("")
                                setBold(true)
                                setGray(1)
                                setAlgin(1)
                                printLogo(resizedBitmap, true)
                                addString(winClaimedResponseData.responseData.gameName)
                                setTextSize(22)
                                addString(printDashStringData(getPaperLength()))
                                setBold(true)
                                setTextSize(24)
                                setBold(false)
                                setAlgin(0)
                                for (i in winClaimedResponseData.responseData.drawData) {
                                    addString(
                                        printTwoStringStringData(
                                            "Draw Date",
                                            getFormattedDateForWinClaim(i.drawDate)
                                        )
                                    )
                                    addString(printTwoStringStringData("Draw Time", i.drawTime))
                                    addString(printTwoStringStringData("Win Status", i.winStatus))
                                    addString(
                                        printTwoStringStringData(
                                            "Winning Amount",
                                            "${i.winningAmount} ${currencyCode}"
                                        )
                                    )
                                    addString(printLineStringData(getPaperLength()))
                                    addString("")
                                }
                                setAlgin(1)
                                setBold(true)
                                setTextSize(24)
                                addString("Reprint Ticket")
                                addString("__________________")
                                addString("")
                                var amount = 0.0
                                var numberString: String
                                setBold(false)
                                if (winClaimedResponseData.responseData.gameCode == "ThaiLottery") {
                                    for (i in 0 until winClaimedResponseData.responseData.panelData.size) {
                                        if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                                "Number",
                                                ignoreCase = true
                                            )
                                        ) {
                                            addString(winClaimedResponseData.responseData.panelData[i].pickedValues)
                                            addString(
                                                printTwoStringStringData(
                                                    "${winClaimedResponseData.responseData.panelData[i].pickDisplayName} : ${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                    "${winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines} $currencyCode"
                                                )
                                            )
                                            addString(
                                                printTwoStringStringData(
                                                    "No of lines",
                                                    "${winClaimedResponseData.responseData.panelData[i].numberOfLines}"
                                                )
                                            )
                                            if (i != winClaimedResponseData.responseData.panelData.size - 1) addString(
                                                printDashStringData(getPaperLength())
                                            )
                                            amount += winClaimedResponseData.responseData.panelData[i].unitCost * winClaimedResponseData.responseData.panelData[i].betAmountMultiple * winClaimedResponseData.responseData.panelData[i].numberOfLines
                                        }
                                    }
                                } else {
                                    val panelDataList =
                                        winClaimedResponseData.responseData.panelData;
                                    panelDataList.let { mPanelData ->
                                        for (i in 0 until mPanelData.size) {
                                            val isQp =
                                                if (winClaimedResponseData.responseData.panelData[i].quickPick) "/QP" else " "
                                            if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Number",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                if (winClaimedResponseData.responseData.panelData[i].pickType.equals(
                                                        "Banker",
                                                        ignoreCase = true
                                                    )
                                                ) {
                                                    numberString =
                                                        winClaimedResponseData.responseData.panelData[i].pickedValues
                                                    val banker: Array<String> =
                                                        numberString.split("-").toTypedArray()

                                                    addString("UL - ${banker[0]}")
                                                    addString("LL - ${banker[1]}")
                                                    if (winClaimedResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${mPanelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    addString(printDashStringData(getPaperLength()))
                                                    amount += mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines

                                                } else {
                                                    addString(mPanelData[i].pickedValues)
                                                    if (winClaimedResponseData.responseData.panelData[i].quickPick) {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${winClaimedResponseData.responseData.panelData[i].betDisplayName}$isQp",
                                                                "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    } else {
                                                        addString(
                                                            printTwoStringStringData(
                                                                "${winClaimedResponseData.responseData.panelData[i].pickDisplayName}/${winClaimedResponseData.responseData.panelData[i].betDisplayName}",
                                                                "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                            )
                                                        )

                                                    }
                                                    addString(
                                                        printTwoStringStringData(
                                                            "No of lines",
                                                            "${mPanelData[i].numberOfLines}"
                                                        )
                                                    )
                                                    if (i != mPanelData.size - 1) addString(
                                                        printDashStringData(getPaperLength())
                                                    )
                                                    amount += mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines
                                                }

                                            } else if (winClaimedResponseData.responseData.panelData[i].pickConfig.equals(
                                                    "Market",
                                                    ignoreCase = true
                                                )
                                            ) {
                                                addString(winClaimedResponseData.responseData.panelData[i].betDisplayName)
                                                addString(
                                                    printTwoStringStringData(
                                                        winClaimedResponseData.responseData.panelData[i].pickDisplayName,
                                                        "${mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines} $currencyCode"
                                                    )
                                                )
                                                addString(
                                                    printTwoStringStringData(
                                                        "No of lines",
                                                        "${mPanelData[i].numberOfLines}"
                                                    )
                                                )
                                                if (i != mPanelData.size - 1) addString(
                                                    printDashStringData(getPaperLength())
                                                )
                                                amount += mPanelData[i].unitCost * mPanelData[i].betAmountMultiple * mPanelData[i].numberOfLines
                                            }
                                        }
                                    }
                                }
                                addString(printLineStringData(getPaperLength()))
                                setTextSize(24)
                                setAlgin(0)
                                addString(printTwoStringStringData("Amount", "$amount"))
                                addString(
                                    printTwoStringStringData(
                                        "No of Draws(s)",
                                        "${winClaimedResponseData.responseData.drawData.size}"
                                    )
                                )
                                setBold(true)
                                addString(
                                    printTwoStringStringData(
                                        "TOTAL AMOUNT",
                                        "${winClaimedResponseData.responseData.totalPurchaseAmount} $currencyCode"
                                    )
                                )
                                setBold(false)
                                addString(" ")
                                setAlgin(1)
                                printLogo(qrCodeHelperObject.qrcOde, true)
                                addString(winClaimedResponseData.responseData.ticketNumber)
                                addString("")
                                addString("$username")
                                addString("")
                                addString("----- FOR DEMO -----")
                                addString("\n")
                                printString()
                                activity.runOnUiThread {
                                    Toast.makeText(
                                        activity,
                                        "Successfully printed",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                result.success(true)

                                try {


                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            }

                        } else {
                            result.error(
                                "-1",
                                "Unable to find printer",
                                "no sunmi or no usb thermal printer"
                            )
                        }
                    }
                }
            }
        }

        channel_print = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mChannelForPrint)

        channel_print.setMethodCallHandler { call, result ->

            val argument = call.arguments as Map<*, *>
            val userName = argument["userName"]
            val userId = argument["userId"]
            val currencyCode = argument["currencyCode"]
            val amount = argument["Amount"]
            val url = argument["url"]

            val bitmap =
                BitmapFactory.decodeResource(context.resources, R.drawable.wls_retail_logo)
            val logo = Bitmap.createScaledBitmap(bitmap, 200, 150, false)

            if (call.method == "notificationPrint") {
                Log.d("TAg", "configureFlutterEngine: notificationPrint method")
                Glide.with(context).asBitmap().load(url).into(object : CustomTarget<Bitmap>() {
                    override fun onResourceReady(
                        resource: Bitmap,
                        transition: com.bumptech.glide.request.transition.Transition<in Bitmap>?
                    ) {
                        val recreatedQrBitmap = Bitmap.createScaledBitmap(resource, 380, 380, true)
                        mSunmiPrinterService?.run {
                            enterPrinterBuffer(true)
                            setAlignment(1, null)
                            sendRAWData(boldFontEnable, null)
                            setFontSize(32f, null)
                            printText("\n---- ${userName} -----", null)
                            sendRAWData(boldFontDisable, null)
                            setFontSize(27f, null)
                            printText("\n${if (userId != 0) "ID : ${userId}" else ""}", null)
                            sendRAWData(boldFontEnable, null)
                            setFontSize(27f, null)
                            printText("\n\n\n----- Amount: ${amount} -----", null)
                            sendRAWData(boldFontDisable, null)
                            printBitmapCustom(recreatedQrBitmap, 0, null)
                            printText("\n-------------------------\n", null)
                            sendRAWData(boldFontEnable, null)
                            setFontSize(23f, null)
                            setAlignment(0, null)
                            printText(
                                "*Note : Please always keep this \nreceipt with you when you want\n cash out your remaining game\n balance.",
                                null
                            )
                            printText(" Go to game portal for \ninitiate withdrawal.", null)
                            sendRAWData(boldFontDisable, null)
                            setAlignment(1, null)
                            printText("\n--------------------------\n", null)
                            printText("\nn\n", null)
                            exitPrinterBufferWithCallback(true, object : InnerResultCallback() {
                                override fun onRunResult(isSuccess: Boolean) {}

                                override fun onReturnString(result: String?) {}

                                override fun onRaiseException(code: Int, msg: String?) {
                                    activity.runOnUiThread {
                                        Toast.makeText(
                                            activity,
                                            "Something went wrong while printing, Please try again",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                    result.error("-1", msg, "Something went wrong while printing")
                                }

                                override fun onPrintResult(code: Int, msg: String?) {
                                    if (updatePrinterState() != 1) {
                                        activity.runOnUiThread {
                                            Toast.makeText(
                                                activity,
                                                "Something went wrong while printing, Please try again",
                                                Toast.LENGTH_SHORT
                                            ).show()
                                        }
                                        result.error(
                                            "-1",
                                            msg,
                                            "Something went wrong while printing"
                                        )

                                    } else {
                                        activity.runOnUiThread {
                                            Toast.makeText(
                                                activity, "Successfully printed", Toast.LENGTH_SHORT
                                            ).show()
                                        }
                                        result.success(true)
                                    }
                                }
                            })

                        } ?: this.let {

                            val usbThermalPrinter = UsbThermalPrinter(activity.baseContext)
                            if (true) {
                                try {
                                    usbThermalPrinter.run {
                                        reset()
                                        start(1)
                                        setGray(1)
                                        setAlgin(1)
                                        printLogo(logo, true)
                                        setTextSize(32)
                                        addString("")
                                        setBold(true)
                                        setAlgin(1)
                                        setTextSize(27)
                                        setBold(false)
                                        addString("---- ${userName} -----")
                                        addString(if (userId != 0) "ID : ${userId}" else "")
                                        addString(" ")
                                        setAlgin(1)
                                        addString(" Amount: $currencyCode ${amount}")
                                        setGray(0)
                                        printLogo(recreatedQrBitmap, true)
                                        setTextSize(22)
                                        addString("*Note : Please always keep this \n" + "receipt with you when you want\n" + " cash out your remaining game\n" + " balance. Go to game portal for " + "initiate withdrawal.")
                                        addString(" ")
                                        setBold(true)
                                        setTextSize(24)
                                        addString(printDashStringData(getPaperLength()))
                                        addString("\n\n")
                                        printString()

                                        activity.runOnUiThread {
                                            Toast.makeText(
                                                activity, "Successfully printed", Toast.LENGTH_SHORT
                                            ).show()
                                        }
                                        result.success(true)
                                    }


                                } catch (e: java.lang.Exception) {
                                    showMsgAccordingToException(e as CommonException, result)
                                    stop()
                                    e.printStackTrace()
                                }
                            } else {
                                android.util.Log.d("TAg", "configureFlutterEngine: no printer")
                                result.error(
                                    "-1",
                                    "Unable to find printer",
                                    "no sunmi or no usb thermal printer"
                                )
                            }
                        }
                    }

                    override fun onLoadCleared(placeholder: Drawable?) {

                    }

                });
            }
        }
    }
    private fun getSelectedOptionsAddOn(options: List<SportsPoolSaleResponse.ResponseData.AddOnDrawData.Board.Event.Option>): String {
        Log.d("TAg", "optionsAddOn: $options")
        // var selectionOptions = ""
        val selectionOptions = StringBuffer()
        selectionOptions.append(" - ")
        for(element in options){
            Log.d("TAg", " element.code AddOn: ${element.code}")
            selectionOptions.append(element.code)
            selectionOptions.append(" ")
            //selectionOptions + " " + element.code
        }
        Log.d("TAg", "selectionOptions AddOn: $selectionOptions")
        return selectionOptions.toString()
    }
    private fun getSelectedOptions(options: List<SportsPoolSaleResponse.ResponseData.MainDrawData.Board.Event.Option>): String {
        Log.d("TAg", "options: $options")
        // var selectionOptions = ""
        val selectionOptions = StringBuffer()
        selectionOptions.append(" - ")
        for(element in options){
            Log.d("TAg", " element.code: ${element.code}")
            selectionOptions.append(element.code)
            selectionOptions.append(" ")
            //selectionOptions + " " + element.code
        }
        Log.d("TAg", "selectionOptions: $selectionOptions")
        return selectionOptions.toString()
    }

    private fun showMsgAccordingToException(exception: CommonException, result: MethodChannel.Result) {

        when (exception) {
            is NoPaperException -> result.error(
                "-1",
                "Please insert the paper before printing",
                "${exception.message}"
            )
            is OverHeatException -> result.error(
                "-1",
                "Device overheated, Please try after some time.",
                "${exception.message}"
            )
            is GateOpenException -> result.error(
                "-1",
                "Something went wrong while printing",
                "${exception.message}"
            )
            is PaperCutException -> result.error(
                "-1",
                "Something went wrong while printing",
                "${exception.message}"
            )
            is TimeoutException -> result.error(
                "-1",
                "Unable to print, Please try after some time.",
                "${exception.message}"
            )
            is FontErrorException -> result.error(
                "-1",
                "Something went wrong while printing",
                "${exception.message}"
            )
            is LowPowerException -> result.error(
                "-1",
                "Low battery, Please charge the device !",
                "${exception.message}"
            )
            else -> result.error(
                "-1",
                "Something went wrong while printing",
                "${exception.message}"
            )

        }
    }

    private fun capitalize(s: String?): String {
        if (s == null || s.isEmpty()) {
            return ""
        }
        val first = s[0]
        return if (Character.isUpperCase(first)) {
            s
        } else {
            first.uppercaseChar().toString() + s.substring(1)
        }
    }

    private fun getDeviceName(): String {
        val manufacturer = Build.MANUFACTURER
        val model = Build.MODEL
        return if (model.lowercase(Locale.getDefault()).startsWith(
                manufacturer.lowercase(
                    Locale.getDefault()
                )
            )
        ) {
            capitalize(model)
        } else {
            if (model.equals("T2mini_s", ignoreCase = true)
            ) capitalize(manufacturer) + " T2mini" else capitalize(manufacturer) + " " + model
        }
    }

    private fun initializeSunmiPrinter() {
        try {
            InnerPrinterManager.getInstance().bindService(this, innerPrinterCallback)
        } catch (e: InnerPrinterException) {
            e.printStackTrace()
        }
    }

    private var innerPrinterCallback: InnerPrinterCallback = object : InnerPrinterCallback() {
        override fun onConnected(sunmiPrinterService: SunmiPrinterService) {
            mSunmiPrinterService = sunmiPrinterService
        }

        override fun onDisconnected() {}
    }

    @SuppressLint("SimpleDateFormat")
    fun getFormattedDateForWinClaim(sourceDate: String): String {
        val input = SimpleDateFormat("yyyy-MM-dd")
        val output = SimpleDateFormat("MMM dd, yyyy")
        try {
            input.parse(sourceDate)?.let {
                return output.format(it)
            }
        } catch (e: Exception) {
            Log.e("log", "Date parsing error: ${e.message}")
        }
        return sourceDate
    }

    @SuppressLint("SimpleDateFormat")
    fun getFormattedDate(sourceDate: String): String {
        val input = SimpleDateFormat("dd-MM-yyyy")
        val output = SimpleDateFormat("MMM dd, yyyy")
        try {
            input.parse(sourceDate)?.let {
                return output.format(it)
            }
        } catch (e: Exception) {
            Log.e("log", "Date parsing error: ${e.message}")
        }
        return sourceDate
    }

    @SuppressLint("SimpleDateFormat")
    fun getFormattedTime(sourceTime: String): String {
        val input = SimpleDateFormat("HH:mm:ss")
        val output = SimpleDateFormat("HH:mm:ss")
        try {
            input.parse(sourceTime)?.let {
                return output.format(it)
            }
        } catch (e: Exception) {
            Log.e("log", "Date parsing error: ${e.message}")
        }
        return sourceTime
    }

    private fun getPaperLength(): Int {
        return "--------------------------".length
    }

    private fun printDashStringData(length: Int): String {
        val str = StringBuffer()
        for (i in 0..length) {
            str.append("-")
        }
        return str.toString()
    }

    private fun printLineStringData(length: Int): String {
        val str = StringBuffer()
        for (i in 0..length) {
            str.append("_")
        }
        return str.toString()
    }

    private fun printTwoStringStringData(one: String, two: String): String {
        val str = StringBuffer()
        val spaceInBetween = getPaperLength() - (one.length + two.length)
        Log.d("TAg", "printTwoStringStringData: $spaceInBetween")
        str.append(one)
        for (i in 0..spaceInBetween) {
            str.append("  ")
        }
        str.append(two)
        return str.toString()
    }

    private fun printThreeStringData(one: String, two: String, three: String): String {
        val str = StringBuffer()
        val spaceInBetween = (getPaperLength() - (one.length + two.length + three.length)) / 2
        Log.d("TAg", "printThreeStringData: $spaceInBetween")
        str.append(one)
        for (i in 0..spaceInBetween) {
            str.append("  ")
        }
        str.append(two)
        for (i in 0..spaceInBetween) {
            str.append("  ")
        }
        str.append(three)
        return str.toString()
    }

}
* */