package main

import (
	"fmt"
	"html/template"
	"net/http"
	"strconv"
)

type CalcData struct {
	W_oc   string
	T_voc  string
	Kp_max string
	W_cv   string
	Za     string
	Zp     string
	Wt     string
	Tbt    string
	Kpt    string
	Pm     string
	Tm     string

	Ka_oc  string
	Kp_oc  string
	W_dk   string
	W_ds   string
	Mw_a   string
	Mw_p   string
	Mz     string
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Server 1 running: http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}

func handler(w http.ResponseWriter, r *http.Request) {
	data := CalcData{
		W_oc:   "0.295",
		T_voc:  "10.7",
		Kp_max: "43",
		W_cv:   "0.02",
		Za:     "23.6",
		Zp:     "17.6",
		Wt:     "0.01",
		Tbt:    "0.045",
		Kpt:    "0.004",
		Pm:     "5120",
		Tm:     "6451",
	}

	if r.Method == http.MethodPost {
		data.W_oc = r.FormValue("w_oc")
		data.T_voc = r.FormValue("t_voc")
		data.Kp_max = r.FormValue("kp_max")
		data.W_cv = r.FormValue("w_cv")
		data.Za = r.FormValue("za")
		data.Zp = r.FormValue("zp")
		data.Wt = r.FormValue("wt")
		data.Tbt = r.FormValue("tbt")
		data.Kpt = r.FormValue("kpt")
		data.Pm = r.FormValue("pm")
		data.Tm = r.FormValue("tm")

		w_oc := parse(data.W_oc)
		t_voc := parse(data.T_voc)
		kp_max := parse(data.Kp_max)
		w_cv := parse(data.W_cv)

		ka_oc := (w_oc * t_voc) / 8760
		kp_oc := (1.2 * kp_max) / 8760
		w_dk := 2 * w_oc * (ka_oc + kp_oc)
		w_ds := w_dk + w_cv

		za := parse(data.Za)
		zp := parse(data.Zp)
		wt := parse(data.Wt)
		tbt := parse(data.Tbt)
		kpt := parse(data.Kpt)
		pm := parse(data.Pm)
		tm := parse(data.Tm)

		mw_a := wt * tbt * pm * tm
		mw_p := kpt * pm * tm
		mz := (za * mw_a) + (zp * mw_p)

		data.Ka_oc = fmt.Sprintf("%.6f", ka_oc)
		data.Kp_oc = fmt.Sprintf("%.6f", kp_oc)
		data.W_dk = fmt.Sprintf("%.6f", w_dk)
		data.W_ds = fmt.Sprintf("%.6f", w_ds)
		data.Mw_a = fmt.Sprintf("%.2f", mw_a)
		data.Mw_p = fmt.Sprintf("%.2f", mw_p)
		data.Mz = fmt.Sprintf("%.2f", mz)
	}

	tmpl, _ := template.New("index").Parse(htmlTemplate)
	tmpl.Execute(w, data)
}

func parse(s string) float64 {
	v, _ := strconv.ParseFloat(s, 64)
	return v
}

const htmlTemplate = `
<!DOCTYPE html>
<html>
<head>
    <title>Lab 5 - Var 5</title>
    <style>
        body { font-family: sans-serif; padding: 20px; background: #f0f2f5; }
        .box { background: white; padding: 30px; width: 600px; margin: 0 auto; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        h2, h3 { text-align: center; color: #333; }
        label { display: block; margin-top: 10px; color: #555; font-size: 0.9em; }
        input { width: 100%; padding: 8px; margin-top: 5px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; background: #007bff; color: white; padding: 10px; border: none; margin-top: 20px; border-radius: 4px; cursor: pointer; }
        .res { margin-top: 20px; padding: 15px; background: #e8f5e9; border: 1px solid #c8e6c9; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Розрахунок надійності ЕПС (Варіант 5)</h2>
        <form method="POST">
            <h3>Завдання 1. Надійність</h3>
            <label>Частота відмов одноколової (ω_oc)</label>
            <input type="text" name="w_oc" value="{{.W_oc}}">
            <label>Час відновлення (t_v.oc)</label>
            <input type="text" name="t_voc" value="{{.T_voc}}">
            <label>Макс. плановий простій (k_p.max)</label>
            <input type="text" name="kp_max" value="{{.Kp_max}}">
            <label>Частота відмов секційного вимикача (ω_cv)</label>
            <input type="text" name="w_cv" value="{{.W_cv}}">

            <h3>Завдання 2. Збитки</h3>
            <label>Аварійні збитки (З_а)</label>
            <input type="text" name="za" value="{{.Za}}">
            <label>Планові збитки (З_п)</label>
            <input type="text" name="zp" value="{{.Zp}}">
            <label>Частота відмов трансформатора (ω)</label>
            <input type="text" name="wt" value="{{.Wt}}">
            <label>Тривалість відновлення (t_b)</label>
            <input type="text" name="tbt" value="{{.Tbt}}">
            <label>Плановий простій (k_p)</label>
            <input type="text" name="kpt" value="{{.Kpt}}">
            <label>Потужність (P_m)</label>
            <input type="text" name="pm" value="{{.Pm}}">
            <label>Час (T_m)</label>
            <input type="text" name="tm" value="{{.Tm}}">

            <button type="submit">Розрахувати</button>
        </form>

        {{if .Ka_oc}}
        <div class="res">
            <h3>Результати</h3>
            <p>Коеф. авар. простою одноколової: {{.Ka_oc}}</p>
            <p>Коеф. план. простою одноколової: {{.Kp_oc}}</p>
            <p>Частота відмов двоколової (без СВ): {{.W_dk}}</p>
            <p>Частота відмов двоколової (з СВ): {{.W_ds}}</p>
            <hr>
            <p>М.С. аварійного недовідпуску: {{.Mw_a}} кВт·год</p>
            <p>М.С. планового недовідпуску: {{.Mw_p}} кВт·год</p>
            <p><strong>Повні збитки: {{.Mz}} грн</strong></p>
        </div>
        {{end}}
    </div>
</body>
</html>
`