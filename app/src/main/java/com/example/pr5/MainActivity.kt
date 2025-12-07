package com.example.pr5

import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.text.Html
import android.text.InputType
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import java.util.Locale

class MainActivity : Activity() {
    private var editLength: EditText? = null
    private var editConnections: EditText? = null
    private var editPmax: EditText? = null
    private var editTmax: EditText? = null
    private var editCostA: EditText? = null
    private var editCostP: EditText? = null

    private var textResult: TextView? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val scrollView = ScrollView(this)
        scrollView.setFillViewport(true)

        val layout = LinearLayout(this)
        layout.orientation = LinearLayout.VERTICAL
        layout.setPadding(40, 40, 40, 40)
        scrollView.addView(layout)

        val title = TextView(this)
        title.text = "Практ. Роб №5 - Калькулятор Надійності"
        title.textSize = 20f
        title.gravity = Gravity.CENTER
        title.setPadding(0, 0, 0, 30)
        title.setTextColor(Color.BLACK)
        layout.addView(title)

        editLength = addInputField(layout, "Довжина лінії (км):", "12.0")
        editConnections = addInputField(layout, "Кількість приєднань:", "8")
        editConnections!!.inputType = InputType.TYPE_CLASS_NUMBER

        editPmax = addInputField(layout, "P_max (кВт):", "5500")
        editTmax = addInputField(layout, "T_max (год):", "5200")
        editCostA = addInputField(layout, "Вартість аварійна (грн):", "24.5")
        editCostP = addInputField(layout, "Вартість планова (грн):", "18.0")

        val btnCalculate = Button(this)
        btnCalculate.text = "РОЗРАХУВАТИ"
        btnCalculate.setBackgroundColor(Color.parseColor("#6200EE")) // Фіолетовий
        btnCalculate.setTextColor(Color.WHITE)

        val btnParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )
        btnParams.setMargins(0, 40, 0, 40)
        layout.addView(btnCalculate, btnParams)

        textResult = TextView(this)
        textResult!!.textSize = 16f
        textResult!!.setBackgroundColor(Color.parseColor("#EEEEEE")) // Світло-сірий фон
        textResult!!.setPadding(30, 30, 30, 30)
        textResult!!.setTextColor(Color.BLACK)
        layout.addView(textResult)

        setContentView(scrollView)

        btnCalculate.setOnClickListener { calculate() }
    }

    private fun addInputField(
        parent: LinearLayout,
        labelText: String,
        defaultValue: String
    ): EditText {
        val label = TextView(this)
        label.text = labelText
        label.setTextColor(Color.DKGRAY)
        parent.addView(label)

        val input = EditText(this)
        input.setText(defaultValue)
        input.inputType = InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL
        parent.addView(input)

        return input
    }

    private fun calculate() {
        try {
            val L_line = editLength!!.text.toString().toDouble()
            val num_connections = editConnections!!.text.toString().toInt()
            val P_max = editPmax!!.text.toString().toDouble()
            val T_max = editTmax!!.text.toString().toDouble()
            val Z_a = editCostA!!.text.toString().toDouble()
            val Z_p = editCostP!!.text.toString().toDouble()

            val w_PL_110 = 0.007
            val w_T_110 = 0.015
            val w_B_110 = 0.01
            val w_B_10 = 0.02
            val w_Lines_10 = 0.03
            val w_Sw_Section = 0.02

            val tv_PL_110 = 10.0
            val tv_T_110 = 100.0
            val tv_B_110 = 30.0
            val tv_B_10 = 15.0
            val tv_Lines_10 = 2.0

            val tp_max = 43.0

            val w_oc = w_B_110 + (w_PL_110 * L_line) + w_T_110 + w_B_10 + (w_Lines_10 * num_connections)

            val t_num = (w_B_110 * tv_B_110) +
                    (w_PL_110 * L_line * tv_PL_110) +
                    (w_T_110 * tv_T_110) +
                    (w_B_10 * tv_B_10) +
                    (w_Lines_10 * num_connections * tv_Lines_10)

            val tv_oc = t_num / w_oc

            val ka_oc = (w_oc * tv_oc) / 8760.0
            val kp_oc = (1.2 * tp_max) / 8760.0

            val w_dk = 2 * w_oc * (ka_oc + kp_oc)
            val w_dc = w_dk + w_Sw_Section

            val Ma = ka_oc * P_max * T_max
            val Mp = kp_oc * P_max * T_max

            val loss_a = Z_a * Ma
            val loss_p = Z_p * Mp
            val loss_total = loss_a + loss_p

            val resultHtml = """
                <h3 align="center">РЕЗУЛЬТАТИ РОЗРАХУНКУ</h3>
                <br>
                <b>ОДНОКОЛОВА СИСТЕМА:</b><br>
                Частота відмов: <b>${String.format(Locale.US, "%.4f", w_oc)} рік⁻¹</b><br>
                Середній час відновлення: <b>${String.format(Locale.US, "%.2f", tv_oc)} год</b><br>
                Коеф. аварійного простою: <b>${String.format(Locale.US, "%.5f", ka_oc)}</b><br>
                Коеф. планового простою: <b>${String.format(Locale.US, "%.5f", kp_oc)}</b><br>
                <br>
                <b>ДВОКОЛОВА СИСТЕМА:</b><br>
                Частота відмов (одночасна): <b>${String.format(Locale.US, "%.4f", w_dk)} рік⁻¹</b><br>
                Частота відмов (з секційним): <b>${String.format(Locale.US, "%.4f", w_dc)} рік⁻¹</b><br>
                <br>
                <b>ЗБИТКИ ВІД ПЕРЕРВ:</b><br>
                Аварійне недовідпущення: <b>${String.format(Locale.US, "%.0f", Ma)} кВт·год</b><br>
                Планове недовідпущення: <b>${String.format(Locale.US, "%.0f", Mp)} кВт·год</b><br>
                Збитки (аварійні): <b>${String.format(Locale.US, "%.2f", loss_a)} грн</b><br>
                Збитки (планові): <b>${String.format(Locale.US, "%.2f", loss_p)} грн</b><br>
                <br>
                <big><b>СУМА ЗБИТКІВ: ${String.format(Locale.US, "%.2f", loss_total)} грн</b></big>
            """.trimIndent()

            textResult!!.text = Html.fromHtml(resultHtml, Html.FROM_HTML_MODE_LEGACY)

        } catch (e: NumberFormatException) {
            Toast.makeText(this, "Помилка! Перевірте правильність введення чисел.", Toast.LENGTH_SHORT).show()
        }
    }
}