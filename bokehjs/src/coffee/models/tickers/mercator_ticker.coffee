import {BasicTicker} from "./basic_ticker"
import * as p from "core/properties"
import {proj4, mercator} from "core/util/proj4"

export class MercatorTicker extends BasicTicker
  type: 'MercatorTicker'

  @define {
    dimension: [ p.LatLon ]
  }

  get_ticks_no_defaults: (data_low, data_high, cross_loc, desired_n_ticks) ->

    if not @dimension?
      throw Error("MercatorTickFormatter.dimension not configured")

    if @dimension == "lon"
      [proj_low,  _] = proj4(mercator).inverse([data_low,  cross_loc])
      [proj_high, _] = proj4(mercator).inverse([data_high, cross_loc])
    else
      [_, proj_low ] = proj4(mercator).inverse([cross_loc, data_low ])
      [_, proj_high] = proj4(mercator).inverse([cross_loc, data_high])

    proj_cross_loc = _
    proj_ticks = super(proj_low, proj_high, cross_loc, desired_n_ticks)

    ticks = {
      major: []
      minor: []
    }

    if @dimension == "lon"
      for tick in proj_ticks.major
        [lon, _] = proj4(mercator).forward([tick, proj_cross_loc])
        ticks.major.push(lon)
      for tick in proj_ticks.minor
        [lon, _] = proj4(mercator).forward([tick, proj_cross_loc])
        ticks.minor.push(lon)
    else
      for tick in proj_ticks.major
        [_, lat] = proj4(mercator).forward([proj_cross_loc, tick])
        ticks.major.push(lat)
      for tick in proj_ticks.minor
        [_, lat] = proj4(mercator).forward([proj_cross_loc, tick])
        ticks.minor.push(lat)

    return ticks