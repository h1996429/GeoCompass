//
//  CoordsTransfer.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/17.
//  Copyright © 2015年 何嘉. All rights reserved.
//

//
//  CoordsTransform.swift
//  KunmingBus
//
//  Created by Yangzheng on 15/2/3.
//  Copyright (c) 2015年 杨政. All rights reserved.
//

import Foundation

// 收藏站点数据表类
class CoordsTransform {
    
    // Krasovsky 1940
    //
    // a = 6378245.0, 1/f = 298.3
    // b = a * (1 - f)
    // ee = (a^2 - b^2) / a^2
    struct Constants {
        // 圆周率
        static let pi: Double = 3.14159265358979324
        // 长轴半径
        static let a: Double = 6378245.0
        // WGS 偏心率的平方
        static let ee: Double = 0.00669342162296594323
        // 计算百度坐标参数
        static let x_pi: Double = 3.14159265358979324 * 3000.0 / 180.0
    }
    
    
    /*******************************************************************************
     *  Descripton: 转换地球坐标为火星坐标 World Geodetic System ==> Mars Geodetic System
     *
     *  Param: wgLat 地球纬度
     *  Param: wgLon 地球经度
     *
     *  Returns: 火星经纬度
     *  ---------------------------------------------------------------------------
     *                Date          Author             Operation
     *             2015-02-03     Yangzheng         Create Function
     ********************************************************************************/
    class func transformGpsToMarsCoords(wgLon: Double, wgLat: Double) -> (mgLon : Double, mgLat: Double)
    {
        var mgLon: Double
        var mgLat: Double
        
        // 判断是否在中国地图范围内
        if outOfChina(wgLon, lat: wgLat)
        {
            mgLon = wgLon
            mgLat = wgLat
            
            return (mgLon, mgLat)
        }
        
        // 转换维度
        var dLat: Double = transformLat((wgLon - 105.0), y: wgLat - 35.0)
        // 转换经度
        var dLon: Double = transformLon((wgLon - 105.0), y: wgLat - 35.0)
        
        let radLat: Double = wgLat / 180.0 * CoordsTransform.Constants.pi
        var magic: Double = sin(radLat)
        
        magic = 1 - CoordsTransform.Constants.ee * magic * magic
        
        let sqrtMagic: Double = sqrt(magic)
        
        dLat = (dLat * 180.0) / ((CoordsTransform.Constants.a * (1 - CoordsTransform.Constants.ee)) / (magic * sqrtMagic) * CoordsTransform.Constants.pi)
        
        dLon = (dLon * 180.0) / (CoordsTransform.Constants.a / sqrtMagic * cos(radLat) * CoordsTransform.Constants.pi)
        
        mgLat = wgLat + dLat
        mgLon = wgLon + dLon
        
        return (mgLon, mgLat)
    }
    
    /*******************************************************************************
     *  Descripton: 火星坐标转地球坐标
     *
     *  Param: lon 经度
     *  Param: lat 纬度
     *
     *  Returns: 地球经纬度
     *  ---------------------------------------------------------------------------
     *                Date          Author             Operation
     *             2015-02-03     Yangzheng         Create Function
     ********************************************************************************/
    class func transformMarsToGpsCoords(lon: Double, lat: Double) -> (gLng: Double, gLat: Double) {
        var gLng: Double
        var gLat: Double
        
        let gpsCoords = transformGpsToMarsCoords(lon, wgLat: lat)
        
        gLng = lon - (gpsCoords.mgLon - lon)
        gLat = lat - (gpsCoords.mgLat - lat)
        
        return (gLng, gLat)
    }
    
    /*******************************************************************************
     *  Descripton: 判断是否在中国境内
     *
     *  Param: lat 纬度
     *  Param: lon 经度
     *
     *  Returns: 布尔值
     *  ---------------------------------------------------------------------------
     *                Date          Author             Operation
     *             2015-02-03     Yangzheng         Create Function
     ********************************************************************************/
    class func outOfChina(lon: Double, lat: Double) -> Bool
    {
        var isOutOfChina = false
        
        if (lon < 72.004 || lon > 137.8347){
            isOutOfChina = true
        }
        if (lat < 0.8293 || lat > 55.8271){
            isOutOfChina =  true
        }
        
        return isOutOfChina;
    }
    
    /*******************************************************************************
     *  *  Descripton: 转换纬度
     *  *
     *  @param x 参数1
     *  @param y 参数2
     *
     *  @return 计算过的纬度
     *  ---------------------------------------------------------------------------
     *                Date          Author             Operation
     *             2015-02-03     Yangzheng         Create Function
     ********************************************************************************/
    class func transformLat(x: Double, y: Double) -> Double
    {
        var ret: Double
        
        ret = 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y - 100.0
        
        ret = ret + 0.2 * sqrt(abs(x))
        
        ret = ret + 20.0 * sin(6.0 * x * CoordsTransform.Constants.pi) * 2.0 / 3.0
        ret = ret + 20.0 * sin(2.0 * x * CoordsTransform.Constants.pi) * 2.0 / 3.0
        ret = ret + 20.0 * sin(y * CoordsTransform.Constants.pi) * 2.0 / 3.0
        ret = ret + 40.0 * sin(y / 3.0 * CoordsTransform.Constants.pi) * 2.0 / 3.0
        ret = ret + 160.0 * sin(y / 12.0 * CoordsTransform.Constants.pi) * 2.0 / 3.0
        ret = ret + 320 * sin(y * CoordsTransform.Constants.pi / 30.0) * 2.0 / 3.0
        
        return ret
    }
    
    /*******************************************************************************
     *  Descripton: 转换经度
     *
     *  Param: x 参数1
     *  Param: y 参数2
     *
     *  Returns: 计算过的经度
     *  ---------------------------------------------------------------------------
     *                Date          Author             Operation
     *             2015-02-03     Yangzheng         Create Function
     ********************************************************************************/
    class func transformLon(x: Double, y: Double) -> Double
    {
        var ret: Double
        
        ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y
        ret = ret + 0.1 * sqrt(abs(x))
        
        ret = ret + 20.0 * sin(6.0 * x * CoordsTransform.Constants.pi)
        ret = ret + 20.0 * sin(2.0 * x * CoordsTransform.Constants.pi) * 2.0 / 3.0
        ret = ret + 20.0 * sin(x * CoordsTransform.Constants.pi) * 2.0 / 3.0
        ret = ret + 40.0 * sin(x / 3.0 * CoordsTransform.Constants.pi) * 2.0 / 3.0
        ret = ret + 150.0 * sin(x / 12.0 * CoordsTransform.Constants.pi) * 2.0 / 3.0
        ret = ret + 300.0 * sin(x / 30.0 * CoordsTransform.Constants.pi) * 2.0 / 3.0
        
        return ret
    }
    
    /*******************************************************************************
     *  Descripton: 火星坐标转换为百度坐标
     *
     *  Param: mLng 火星经度
     *  Param: mLat 火星纬度
     *
     *  Returns: 百度坐标
     *  ---------------------------------------------------------------------------
     *                Date          Author             Operation
     *             2015-02-03     Yangzheng         Create Function
     ********************************************************************************/
    class func transformMarsToBaiduCoords(mLng: Double, mLat: Double) -> (bLng: Double, bLat: Double)
    {
        var bLng: Double
        var bLat: Double
        
        let x = mLng
        let y = mLat
        
        let z: Double = sqrt(x * x + y * y) + 0.00002 * sin(y * CoordsTransform.Constants.x_pi)
        
        let theta = atan2(y, x) + 0.000003 * cos(x * CoordsTransform.Constants.x_pi)
        
        bLng = z * cos(theta) + 0.0065
        
        bLat = z * sin(theta) + 0.006
        
        return (bLng, bLat)
        
    }
    
    /*******************************************************************************
     *  Descripton: 将百度坐标转换为火星坐标
     *
     *  Param: bLng 百度经度
     *  Param: bLat 百度纬度
     *
     *  Returns: 火星坐标
     *  ---------------------------------------------------------------------------
     *                Date          Author             Operation
     *             2015-02-03     Yangzheng         Create Function
     ********************************************************************************/
    class func transformBaiduToMarsCoords(bLng: Double, bLat: Double) -> (mLng: Double, mLat: Double)
    {
        var mLng: Double
        var mLat: Double
        
        let x = bLng - 0.0065
        let y = bLat - 0.006
        
        let z = sqrt(x * x + y * y) - 0.00002 * sin(y * CoordsTransform.Constants.x_pi)
        
        let theta = atan2(y, x) - 0.000003 * cos(x * CoordsTransform.Constants.x_pi)
        
        mLng = z * cos(theta)
        mLat = z * sin(theta)
        
        return (mLng, mLat)
    }
}