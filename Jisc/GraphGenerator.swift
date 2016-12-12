//
//  GraphGenerator.swift
//  Jisc
//
//  Created by Therapy Box on 10/23/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
import Charts

class GraphGenerator: NSObject {
	
	class func maskView(_ sender:UIView, withPath:UIBezierPath) {
		let layer = CAShapeLayer()
		layer.frame = sender.bounds
		layer.path = withPath.cgPath
		sender.layer.mask = layer
	}
	
	class func drawGraphInView(_ view:UIView, frame:CGRect, values:[Double], animationDuration:Double) -> LineChartView {
		let chartView = LineChartView(frame: frame)
		view.addSubview(chartView)
		
		chartView.setViewPortOffsets(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
		chartView.backgroundColor = UIColor.clear
		chartView.descriptionText = ""
		chartView.noDataTextDescription = ""
		chartView.dragEnabled = false
		chartView.scaleXEnabled = true
		chartView.pinchZoomEnabled = false
		chartView.drawGridBackgroundEnabled = false
		chartView.xAxis.enabled = false
		chartView.leftAxis.enabled = false
		chartView.rightAxis.enabled = false
		chartView.legend.enabled = false
		chartView.isUserInteractionEnabled = false
		
		var yVals1 = [ChartDataEntry]()
		
		for (index, item) in values.enumerated() {
			yVals1.append(ChartDataEntry(x: Double(index), y: item))
//			yVals1.append(ChartDataEntry(value: item, xIndex: index))
		}
		
//		let set1 = LineChartDataSet(yVals: yVals1, label: "DataSet 1")
		let set1 = LineChartDataSet(values: yVals1, label: "DataSet 1")
		set1.mode = .cubicBezier
		set1.cubicIntensity = 0.2;
		set1.drawCirclesEnabled = false
		set1.setColor(UIColor.clear)
		set1.fillColor = appPurpleColor
		set1.fillAlpha = 1.0
		set1.drawHorizontalHighlightIndicatorEnabled = false
		
//		let data = LineChartData(xVals: xVals, dataSet: set1)
		let data = LineChartData(dataSets: [set1])
		data.setValueFont(myriadProRegular(20)!)
		data.setDrawValues(false)
		
		chartView.data = data;
		
		for (_, item) in chartView.data!.dataSets.enumerated() {
			(item as! LineChartDataSet).drawFilledEnabled = true
		}
		
		chartView.animate(xAxisDuration: animationDuration, yAxisDuration: animationDuration)
		
		return chartView
	}
	
	class func drawPieChartInView(_ view:UIView, frame: CGRect, fillValue:Double, animationDuration:Double, color:UIColor) -> PieChartView {
		
		let fillValue = min(1, fillValue)
		let chartView = PieChartView(frame: frame)
		view.addSubview(chartView)
		
		chartView.backgroundColor = UIColor.clear
		chartView.usePercentValuesEnabled = true
		chartView.holeColor = UIColor.clear
		chartView.holeRadiusPercent = 0.66
		chartView.holeColor = UIColor.clear
		chartView.transparentCircleRadiusPercent = 0.66
		chartView.descriptionText = ""
		chartView.setExtraOffsets(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
		chartView.legend.enabled = false
		chartView.drawCenterTextEnabled = false
		chartView.drawHoleEnabled = true
		chartView.rotationAngle = -90.0
		chartView.rotationEnabled = false
		chartView.isUserInteractionEnabled = false
		
		var yVals1 = [BarChartDataEntry]()
//		yVals1.append(BarChartDataEntry(value: fillValue, xIndex: 0))
//		yVals1.append(BarChartDataEntry(value: 1.0 - fillValue, xIndex: 1))
		
		yVals1.append(BarChartDataEntry(x: 0, yValues: [fillValue]))
		yVals1.append(BarChartDataEntry(x: 1, yValues: [1.0 - fillValue]))
		
//		let dataSet = PieChartDataSet(yVals: yVals1, label: "")
		let dataSet = PieChartDataSet(values: yVals1, label: "")
		dataSet.sliceSpace = 0.0
		
		let colors = [color, UIColor.lightGray.withAlphaComponent(0.4)]
		dataSet.colors = colors
		
//		let data = PieChartData(xVals: xVals, dataSet: dataSet)
		let data = PieChartData(dataSet: dataSet)
		data.setValueTextColor(UIColor.clear)
		
		chartView.data = data;
		chartView.highlightValues(nil)
		
		chartView.animate(xAxisDuration: animationDuration, yAxisDuration: animationDuration, easingOption: ChartEasingOption.easeInBack)
		
		return chartView
	}
	
	class func drawLineGraphInView(_ view:UIView, frame:CGRect, values:[[Double]], colors:[UIColor], animationDuration:Double) -> LineChartView {
		let chartView = LineChartView(frame: frame)
		view.addSubview(chartView)
		
		chartView.backgroundColor = UIColor.clear
		chartView.descriptionText = ""
		chartView.noDataTextDescription = ""
		chartView.dragEnabled = false
		chartView.scaleXEnabled = true
		chartView.pinchZoomEnabled = false
		chartView.drawGridBackgroundEnabled = false
		chartView.xAxis.enabled = false
		chartView.leftAxis.enabled = false
		chartView.rightAxis.enabled = false
		chartView.legend.enabled = false
		chartView.isUserInteractionEnabled = false
		chartView.setViewPortOffsets(left: 1.0, top: 1.0, right: 1.0, bottom: 1.0)
		
		var dataSets = [ChartDataSet]()
		
		for (aIndex, array) in values.enumerated() {
		
			var yVals = [ChartDataEntry]()
			for (index, item) in array.enumerated() {
//				yVals.append(ChartDataEntry(value: item, xIndex: index))
				yVals.append(ChartDataEntry(x: Double(index), y: item))
			}
			
//			let set = LineChartDataSet(yVals: yVals, label: "")
			let set = LineChartDataSet(values: yVals, label: "")
			set.cubicIntensity = 0.0;
			set.drawCirclesEnabled = false
			set.setColor(colors[aIndex])
			set.fillColor = UIColor.clear
			set.fillAlpha = 0.0
			set.lineWidth = 1.0
			set.drawHorizontalHighlightIndicatorEnabled = false
			
			dataSets.append(set)
		}
		
//		let data = LineChartData(xVals: xVals, dataSets: dataSets)
		let data = LineChartData(dataSets: dataSets)
		data.setDrawValues(false)
		
		chartView.data = data
		
		if (chartView.data != nil) {
			for (_, item) in chartView.data!.dataSets.enumerated() {
				(item as! LineChartDataSet).drawFilledEnabled = false
			}
		}
		
		chartView.animate(xAxisDuration: animationDuration, yAxisDuration: animationDuration)
		
		return chartView
	}
	
	class func drawBarChartInView(_ view:UIView, frame:CGRect, values:[[Double]], colors:[UIColor]) -> UIView {
		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.backgroundColor = UIColor.clear
		let leading = NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
		let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
		let top = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
		let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		view.addSubview(containerView)
		view.addConstraints([leading, trailing, top, bottom])
		let width = NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: frame.size.width)
		let height = NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: frame.size.height)
		containerView.addConstraints([width, height])
		view.layoutIfNeeded()
		var maxValue:Double = 0.0
		var valuePairs:[(myValue:Double, otherValue:Double)] = [(myValue:Double, otherValue:Double)]()
		for (student, valuesArray) in values.enumerated() {
			for (index, value) in valuesArray.enumerated() {
				if maxValue < value {
					maxValue = value
				}
				if student == 0 {
					let aPair:(myValue:Double, otherValue:Double) = (value, 0.0)
					valuePairs.append(aPair)
				} else {
					valuePairs[index].otherValue = value
				}
			}
		}
		var lastView:UIView?
		var firstView:UIView?
		if values.count == 1 {
			for (_, value) in values[0].enumerated() {
				let barView = SingleBarView.create(value, percentage: value / maxValue, color: colors[0])
				GraphGenerator.insertBarView(barView, view: containerView, lastView: lastView, firstView: firstView)
				lastView = barView
				if firstView == nil {
					firstView = barView
				}
			}
		} else {
			for (_, pair) in valuePairs.enumerated() {
				let barView = DoubleBarView.create(pair.myValue, myPercentage: pair.myValue / maxValue, myColor: colors[0], otherValue: pair.otherValue, otherPercentage: pair.otherValue / maxValue, otherColor: colors[1])
				GraphGenerator.insertBarView(barView, view: containerView, lastView: lastView, firstView: firstView)
				if firstView == nil {
					firstView = barView
				}
				lastView = barView
			}
		}
		if let lastView = lastView {
			let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: lastView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
			view.addConstraint(trailing)
		}
		return containerView
	}
	
	class func insertBarView(_ barView:UIView, view:UIView, lastView:UIView?, firstView:UIView?) {
		view.addSubview(barView)
		let top = NSLayoutConstraint(item: barView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
		let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: barView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		view.addConstraints([top, bottom])
		if let lastView = lastView {
			let horizontal = NSLayoutConstraint(item: lastView, attribute: .trailing, relatedBy: .equal, toItem: barView, attribute: .leading, multiplier: 1.0, constant: 10.0)
			view.addConstraint(horizontal)
		} else {
			let leading = NSLayoutConstraint(item: barView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
			view.addConstraint(leading)
		}
		if let firstView = firstView {
			let width = NSLayoutConstraint(item: firstView, attribute: .width, relatedBy: .equal, toItem: barView, attribute: .width, multiplier: 1.0, constant: 0.0)
			view.addConstraint(width)
		}
	}
}
