//
//  ViewController.swift
//  LabSignalsProcessing
//
//  Created by Artjom Bastun on 11/22/15.
//  Copyright © 2015 Artjom Bastun. All rights reserved.
//

import UIKit
import Charts
import Accelerate

// MARK: Square Root

public func sqrt(_ x: [Float]) -> [Float] {
	var results = [Float](repeating: 0.0, count: x.count)
  vvsqrtf(&results, x, [Int32(x.count)])
  
  return results
}

public func sqrt(_ x: [Double]) -> [Double] {
	var results = [Double](repeating: 0.0, count: x.count)
  vvsqrt(&results, x, [Int32(x.count)])
  
  return results
}

// MARK: FFT

public func fft(_ input: [Float]) -> [Float] {
  var real = [Float](input)
	var imaginary = [Float](repeating: 0.0, count: input.count)
  var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
  
  let length = vDSP_Length(floor(log2(Float(input.count))))
  let radix = FFTRadix(kFFTRadix2)
  let weights = vDSP_create_fftsetup(length, radix)
  vDSP_fft_zip(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
  
	var magnitudes = [Float](repeating: 0.0, count: input.count)
  vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
  
	var normalizedMagnitudes = [Float](repeating: 0.0, count: input.count)
  vDSP_vsmul(sqrt(magnitudes), 1, [2.0 / Float(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
  
  vDSP_destroy_fftsetup(weights)
  
  return normalizedMagnitudes
}

public func fft(_ input: [Double]) -> [Double] {
  var real = [Double](input)
	var imaginary = [Double](repeating: 0.0, count: input.count)
  var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)
  
  let length = vDSP_Length(floor(log2(Float(input.count))))
  let radix = FFTRadix(kFFTRadix2)
  let weights = vDSP_create_fftsetupD(length, radix)
  vDSP_fft_zipD(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
  
	var magnitudes = [Double](repeating: 0.0, count: input.count)
  vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
  
	var normalizedMagnitudes = [Double](repeating: 0.0, count: input.count)
  vDSP_vsmulD(sqrt(magnitudes), 1, [2.0 / Double(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
  
  vDSP_destroy_fftsetupD(weights)
  
  return normalizedMagnitudes
}

class ViewController: UIViewController {

  @IBOutlet weak var chartView: LineChartView!
  @IBOutlet weak var minLabel: UILabel!
  @IBOutlet weak var maxLabel: UILabel!
  @IBOutlet weak var peakLabel: UILabel!
  @IBOutlet weak var rmsLabel: UILabel!
  @IBOutlet weak var peakFactorLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    chartView.dragEnabled = true
    chartView.setScaleEnabled(true)
    chartView.pinchZoomEnabled = false
    chartView.drawGridBackgroundEnabled = false
    chartView.chartDescription?.text = ""
    
    chartView.xAxis.enabled = true
    chartView.xAxis.labelPosition = .bottom
    chartView.xAxis.drawGridLinesEnabled = false
    
    let yAxis = chartView.leftAxis;
    yAxis.axisMinimum = -1
    yAxis.axisMaximum = 1
		yAxis.labelFont = UIFont.systemFont(ofSize: 10)
//    yAxis.startAtZeroEnabled = false
//    yAxis.labelTextColor = UIColor.whiteColor;
//    yAxis.labelPosition = YAxisLabelPosition.InsideChart
    yAxis.drawGridLinesEnabled = false
//    yAxis.axisLineColor = UIColor.whiteColor;
    
    chartView.rightAxis.enabled = false
    chartView.legend.enabled = true
    
		guard let filePath = Bundle.main.path(forResource: "PRIM1", ofType: "TXT") else {
      return;
    }
		guard let fileContent = try? String(contentsOfFile: filePath, encoding: .utf8) else {
      return
    }
    
		var lines = fileContent.split(separator: "\r\n")
    let count = Int(lines.first!)!
    
    for i in 1...count {
      if lines[i].count == 0 || lines[i] == " " {
				lines.remove(at: i)
      }
    }
    
//    var signal = [] as [Double]
//    for i in 1..<lines.count {
//      let val = Double(lines[i])
//      if val != nil {
//        signal.append(val!)
//      }
//    }
//    
//    var yVals = [] as [Double]
//    for ind in 0..<count {
//      let index = ind * signal.count / count
//      yVals.append(signal[index])
//    }
    
    var yVals = [] as [Double]
    for ind in 1...count {
      let val = Double(lines[ind])!
      yVals.append(val)
    }
    
    var xVals = [] as [String]
    
    for i in 0..<count {
      xVals.append(String(i))
    }
    
    var yVals1 = [] as [ChartDataEntry]
    
    for i in 0..<count {
			let entry = ChartDataEntry(x: Double(i), y: yVals[i])
      yVals1.append(entry)
    }
    
    let fftVals = fft(yVals)
    
    var yVals2 = [] as [ChartDataEntry]
    
    for i in 0..<count {
			let entry = ChartDataEntry(x: Double(i), y: fftVals[i])
      yVals2.append(entry)
    }
    
		let set1 = LineChartDataSet(values: yVals1, label: "Signal")
		set1.mode = .cubicBezier
    set1.cubicIntensity = 0.2
    set1.drawCirclesEnabled = false
    set1.lineWidth = 1.8;
    set1.circleRadius = 4.0;
//    [set1 setCircleColor:UIColor.whiteColor];
//    set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
//    set1.setColor(UIColor.blueColor())
//    set1.fillColor = UIColor.whiteColor;
    set1.fillAlpha = 1
    set1.drawHorizontalHighlightIndicatorEnabled = false
//    set1.fillFormatter = CubicLineSampleFillFormatter()
    
		let set2 = LineChartDataSet(values: yVals2, label: "Amplitude spectrum")
    set2.mode = .cubicBezier
    set2.cubicIntensity = 0.2
    set2.drawCirclesEnabled = false
    set2.lineWidth = 1.8;
    set2.circleRadius = 4.0;
    //    [set1 setCircleColor:UIColor.whiteColor];
    //    set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
		set2.setColor(.red)
    //    set1.fillColor = UIColor.whiteColor;
    set2.fillAlpha = 1
    set2.drawHorizontalHighlightIndicatorEnabled = false
    //    set1.fillFormatter = CubicLineSampleFillFormatter()
    
//    let data = LineChartData(values: xVals, dataSets: [set1, set2])
		let data = LineChartData(dataSets: [set1, set2])
//    let data = LineChartData(xVals: xVals, dataSet: set1)
		data.setValueFont(UIFont.systemFont(ofSize: 9))
    data.setDrawValues(false)
    
    chartView.data = data;
    
		let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 6
		minLabel.text = "Min: \(numberFormatter.string(from: NSNumber(value: set1.yMin))!)"
		maxLabel.text = "Max: \(numberFormatter.string(from: NSNumber(value: set1.yMax))!)"
    let peak = set1.yMax - set1.yMin
		peakLabel.text = "Range: \(numberFormatter.string(from: NSNumber(value: peak))!)"
		let values = set1.values.map({ $0.y })
		let squareSum = values.reduce(Double(0)) { $0 + $1*$1 }
    let squareRMS = squareSum / Double(set1.values.count)
    let rms = sqrt(squareRMS)
		rmsLabel.text = "RMS: \(numberFormatter.string(from: NSNumber(value: rms))!)"
		peakFactorLabel.text = "Peak Factor: \(numberFormatter.string(from: NSNumber(value: set1.yMax / rms))!)"
  }
}

