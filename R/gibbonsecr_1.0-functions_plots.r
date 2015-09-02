## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##

plot_bearings = function(capthist, session = NULL, group = NULL, length = 0.05, legend = TRUE, buffer = 6000, add = FALSEL){
    if(!inherits(capthist, "capthist"))
        stop("expecting a capthist object")
    capthist = MS(capthist)
    if(is.null(get_bearings(capthist)))
        stop("no bearings to plot")
    sessions = if(is.null(session)) session(capthist) else session
    for(session in sessions){ # session = sessions[1] ; session
        sescapt = capthist[[session]]
        n = n_groups(sescapt)    ; n
        if(n == 0) next
        S = n_occasions(sescapt) ; S
        K = n_traps(sescapt)     ; K
        sestraps = traps(sescapt)

        ##############################################
        ## bearings and distances

        bearings = get_bearings(sescapt)
        # print(bearings) ; stop()
        if(!is.null(bearings)){
            if(attr(bearings, "details")$units == "degrees")
                bearings = bearings * pi/180
        }else next
        distances = get_distances(sescapt)
        if(!is.null(distances)){
            if(attr(distances, "details")$units == "km")
                distances = distances * 1000
            if(is.null(buffer)) buffer = max(distances)
        }

        ##############################################
        ## set up plot

        if(!add){
            buffer.contour(sestraps, buffer, asp = 1, bty = "n", axes = FALSE, col = grey(0.99))
            box()
            plot_traps(sestraps, add = TRUE)
        }

        ##############################################
        ## extract group

        if(!is.null(group)){
            row = which(rownames(sescapt) == group)
            if(length(row) == 0)
                stop("cant find group ID in capthist")
            sescapt = sescapt[row, , , drop = FALSE]
            if(is.null(bearings))
                bearings = bearings[row, , , drop = FALSE]
            if(is.null(distances))
                distances = distances[row, , , drop = FALSE]
        }

        ##############################################
        ## bearing arrows

        index = if(is.null(distances)){
            which(!is.na(bearings), arr.ind = TRUE)
        }else{
            which(!is.na(bearings) & !is.na(distances), arr.ind = TRUE)
        }
        i = sort(unique(index[,1])) ; i
        if(!is.null(attr(sescapt, "locations")))
            points(attr(sescapt, "locations"), col = i, cex = 0.5, pch = 19)
        if(legend) legend("topright", rownames(sescapt)[i], col = i, lty = 1,
                          title = "group", bty = "n")
        for(det in 1:nrow(index)){ # det = 1
            i = index[det,1] ; i
            s = index[det,2] ; s
            k = index[det,3] ; k
            draw_bearing_arrows(
                bearing  = bearings[i,s,k],
                distance = if(is.null(distances)) buffer / 2 else distances[i,s,k],
                col      = i,
                origin   = as.data.frame(sestraps[k,]),
                length   = length
            )
        }
    }
    invisible()
}

## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##

plot_capthist = function(x, mask = NULL){
    if(!inherits(x, c("gibbonsecr_fit", "secr", "capthist")))
        stop("x must be a gibbonsecr_fit, secr or capthist object")
    if(!is.null(mask))
        if(!inherits(mask, "mask"))
            stop("requires a 'mask' object")
    if(inherits(x, c("gibbonsecr_fit", "secr"))){
        x = x$capthist
        if(is.null(mask)) mask = x$mask
    }
    x = MS(x)
    if(!is.null(mask)) mask = MS(mask)
    lim = function(x) apply(do.call(rbind, lapply(x, as.matrix)), 2, range)
    lim = if(is.null(mask)) lim(traps(x)) else lim(mask)
    plot(0, 0, xlim = lim[,1], ylim = lim[,2], asp = 1, xlab = "x", ylab = "y")
    for(i in 1:length(x)){ # i=1
        traps = traps(x[[i]])
        points(traps, col = i, pch = 15)
        if(!is.null(mask)){
            # points(as.data.frame(mask[[i]]), col = i, pch = 15)
            buffer.contour(traps, mask_buffer(mask[[i]], traps), col = i, lty = ceiling(i / 10), add = TRUE)
        }
    }
    title("Listening post locations")
    invisible()
}

## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##

plot_detectfn_auxiliary = function(fit, which = c("detectfn","bearings","distances"), session = 1, CI = TRUE, alpha = 0.05, nx = 100, use.global.par.settings = FALSE, ...){
    which = match.arg(which)
    plotargs = list(...) # plotargs = list() ; which = "bearings" ; session = "2" ; nx = 100
    plotargs$x = switch(
        which,
        "detectfn"  = seq(0, mask_buffer(fit$mask, fit$capthist), length = nx),
        "bearings"  = seq(-pi/2, pi/2, length = nx),
        "distances" = seq(0, 2000, length = nx)
    )

    ##################################################
    ## delta method

    deltaargs = list(beta = coef(fit), fit = fit, x = plotargs$x, session = session, which = which)
    if(CI){
        deltaargs$f = fitted_detectfn_auxiliary_values
        deltaargs$vcov = vcov(fit)
        delta = do.call(delta_method, deltaargs)
        zvalue = qnorm(1 - alpha / 2)
        delta$lower = delta$est - zvalue * delta$se
        delta$upper = delta$est + zvalue * delta$se
        delta$se = NULL
    }else{
        delta = list(est = do.call(fitted_detectfn_auxiliary_values, deltaargs))
    }
    plotargs$y = delta$est
    if(which == "bearings") plotargs$x = plotargs$x * 180/pi

    ##################################################
    ## plot

    # set up plotting area if add = NULL or FALSE
    if(is.null(plotargs$add) || !plotargs$add){
        plotargs$type = "n"
        if(is.null(plotargs$main)) plotargs$main = switch(
            which,
            "detectfn"  = "Detection function",
            "bearings"  = "Bearing error distribution",
            "distances" = "Distance error distribution (truth = 1000m)"
        )
        if(is.null(plotargs$xlab)) plotargs$xlab = switch(
            which,
            "detectfn"  = "Distance from detector (m)",
            "bearings"  = "Bearing error (degrees)",
            "distances" = "Distance estimate (m)"
        )
        if(is.null(plotargs$ylab)) plotargs$ylab = switch(
            which,
            "detectfn"  = "Detection probability",
            "Probability density"
        )
        if(is.null(plotargs$xaxs)) plotargs$xaxs = "i"
        if(is.null(plotargs$yaxs)) plotargs$yaxs = "i"
        if(is.null(plotargs$bty))  plotargs$bty  = "n"
        if(is.null(plotargs$ylim)) plotargs$ylim = switch(
            which,
            "detectfn"  = c(0,1),
            c(0, max(sapply(delta,max)))
        )
        do.call(plot, plotargs)
    }
    # draw plot
    plotargs[c("add","type","main","xlab","ylab","xaxs","yaxs","bty","xlim","ylim")] = NULL
    plotargs$type = NULL
    plotargs$lty = 1
    do.call(lines, plotargs)
    if(CI){
        plotargs$lty = 2
        for(interval in c("lower","upper")){
            plotargs$y = delta[[interval]]
            do.call(lines, plotargs)
        }
    }
    invisible()
}

## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##

#' @title Plot a fitted model
#' @description TODO
#' @inheritParams print.gibbonsecr_fit
#' @param which TODO
#' @param session TODO
#' @param use.global.par.settings TODO
#' @details TODO
#' @author Darren Kidney \email{darrenkidney@@googlemail.com}
#' @seealso \link{gibbonsecr_fit}
#' @method plot gibbonsecr_fit
#' @export

plot.gibbonsecr_fit = function(x, which = c("detectfn","pdot","bearings","distances","density"), session = 1, use.global.par.settings = TRUE, ...){
    which = match.arg(which)
    # which = "pdot"; session = 1; use.global.par.settings = TRUE
    if(!ms(x$capthist)) stop("only works for multi-session data")
    if(which %in% c("bearings","distances"))
        if(x$model.options[[which]] == 0) stop("no ", which, " model")
    if(is.numeric(session))
        session = session(x$capthist)[session]
    if(!use.global.par.settings) pop = par(no.readonly = TRUE)
    if(which %in% c("detectfn","bearings","distances")){
        if(!use.global.par.settings)
            pop = par(mfrow = c(1,1), oma = c(0,0,0,0), mar = c(4,4,2,2))
        plot_detectfn_auxiliary(x, which = which, ...)
    }else{
        if(!use.global.par.settings)
            par(mfrow = c(1,1), oma = c(0,0,0,0), mar = c(4,4,2,6))
        plot_surface(x, which = which, session = session, ...)
    }
    # usr = par()$usr
    # mfg = par()$mfg
    if(!use.global.par.settings) par(pop)
    # par(usr = usr, mfg = mfg)
    invisible()
}

## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##

# @title Plot simulation results
# @description TODO
# @inheritParams print.gibbonsecr_fit
# @param CI TODO
# @param exp TODO
# @param use.global.par.settings TODO
# @details TODO
# @author Darren Kidney \email{darrenkidney@@googlemail.com}
# @seealso \link{gibbonsecr_sim}
# @method plot gibbonsecr_sim
# @export

plot.gibbonsecr_sim = function(x, CI = TRUE, exp = FALSE, use.global.par.settings = FALSE, ...){

    ##################################################
    ## par settings

    if(!use.global.par.settings){
        pop = par(no.readonly = TRUE)
        on.exit(par(pop))
        npars = ncol(x$gibbonsecr_fit)
        par(mfrow = n2mfrow(npars), mar = c(2,2,2,2), oma = c(0,0,2,0))
    }

    ##################################################
    ## modify secr.fit par names and D values

    if(!is.null(x$secr.fit)){
        for(par in c("D", "g0", "sigma", "z")){ # par = "D"
            i = match(par, colnames(x$secr.fit))
            if(length(i) > 0)
                colnames(x$secr.fit)[i] = paste0(colnames(x$secr.fit)[i], ".(Intercept)")
            if(par == "D"){
                x$secr.fit[,i] = x$secr.fit[,i] + log(100)
            }
        }
    }

    ##################################################
    ## draw histograms

    for(par in colnames(x$gibbonsecr_fit)){ # par = colnames(x$gibbonsecr_fit)[1] ; par

        ##################################################
        ## gibbonsecr_fit results

        col = colnames(x$gibbonsecr_fit) == par
        truth  = attr(x, "truth")[col]
        est1   = x$gibbonsecr_fit[,col]
        mu1    = mean(est1)
        se1    = sd(est1) / sqrt(length(est1))
        upper1 = mu1 + 1.96 * se1
        lower1 = mu1 - 1.96 * se1
        if(exp){
            truth  = exp(truth)
            est1   = exp(est1)
            mu1    = exp(mu1)
            se1    = exp(se1)
            upper1 = exp(upper1)
            lower1 = exp(lower1)
        }
        xrange = range(c(est1, truth))

        ##################################################
        ## secr.fit results

        if(!is.null(x$secr.fit)){
            col = colnames(x$secr.fit) == par
            if(any(col)){
                est0   = x$secr.fit[,col]
                mu0    = mean(est0)
                se0    = sd(est0) / sqrt(length(est0))
                upper0 = mu0 + 1.96 * se0
                lower0 = mu0 - 1.96 * se0
                if(exp){
                    est0   = exp(est0)
                    mu0    = exp(mu0)
                    se0    = exp(se0)
                    upper0 = exp(upper0)
                    lower0 = exp(lower0)
                }
                xrange = range(c(est0, xrange))
            }
        }

        ##################################################
        ## density plot

        plot(density(est1), main = par, xlab = "", ylab = "", xlim = xrange, col = 4)
        abline(v = truth, lty = 2)
        abline(v = mu1, col = 4)
        if(CI) abline(v = c(upper1, lower1), lty = 3, col = 4)

        if(!is.null(x$secr.fit) && any(col)){
            lines(density(est0), col = 2)
            abline(v = mu0, col = 2)
            if(CI) abline(v = c(upper0, lower0), lty = 3, col = 2)
        }
    }

    ##################################################
    ## add title

    if(!use.global.par.settings){
        title(attr(x, "simname"), outer = TRUE)
        par(op)
    }

    invisible()

}

## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##

# @title TODO
# @description TODO
# @param mask TODO
# @param traps TODO
# @param region TODO
# @param add TODO
# @param covariate TODO
# @param col TODO
# @param pch TODO
# @param bty TODO
# @param axes TODO
# @param xlab TODO
# @param ylab TODO
# @param main TODO
# @param legend TODO
# @param xaxs TODO
# @param yaxs TODO
# @author Darren Kidney \email{darrenkidney@@googlemail.com}
# @export
plot_mask = function(mask, session = NULL, traps = NULL, region = NULL, add = FALSE, covariate = NULL, col = NULL, pch = 15, bty = "n", axes = FALSE, xlab = "", ylab = "", main = "", legend = TRUE, xaxs = "r", yaxs = "r", type = "p"){
    if(!inherits(mask, "mask"))
        stop("requires a mask object", call. = FALSE)
    if(ms(mask) && !is.null(session)) mask = mask[[session]]
    if(!add){
        bbox = mask_bbox(mask)
        plot(bbox, type = "n", asp = 1, bty = bty, axes = axes, xlab = xlab, ylab = ylab, main = main, xaxs = xaxs, yaxs = yaxs)
    }
    if(type != "n"){
        if(!is.null(covariate)){
            present = if(ms(mask)){
                !is.null(covariates(mask[[1]])[[covariate]])
            }else{
               !is.null(covariates(mask)[[covariate]])
            }
            if(!present){
                message("cant find covariate: ", covariate)
                covariate = NULL
            }
        }
        plot(mask, add = TRUE, pch = pch, covariate = covariate, col = col, legend = legend)
        if(!is.null(traps)) plot_traps(traps, add = TRUE)
        if(!is.null(region)) sp::plot(region, add = TRUE)
    }
    invisible()
}

## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##

# @title TODO
# @description TODO
# @param shp TODO
# @param traps TODO
# @param add TODO
# @author Darren Kidney \email{darrenkidney@@googlemail.com}
# @export
plot_shp = function(shp, traps = NULL, add = FALSE){
    if(!inherits(shp, c("SpatialPolygons")))
        stop("requires a SpatialPolygons object", call. = FALSE)
    if(!add){
        plot(t(attr(shp, "bbox")), type = "n", asp = 1)
    }
    n_layers = length(shp@polygons)
    col = if(n_layers == 1) NA else terrain.colors(n_layers)
    sp::plot(shp, col = col, add = TRUE)
#     lapply(1:n_layers, function(i){ # i=1
#         lapply(shp@polygons[[i]]@Polygons, function(x){
#             # x = shp@polygons[[i]]@Polygons[[1]]
#             # x = shp@polygons[[i]]@Polygons[[2]]
#             polygon(x@coords, col = col[i], border = NA)
#             # points(x@coords, col = col[i])
#         })
#     })
    if(!is.null(traps)){
        plot_traps(traps, add = TRUE)
    }
    invisible()
}

## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##

plot_surface = function(fit, which = c("pdot","density"), CI = FALSE, contour = TRUE, centered = FALSE, session, ...){
    which = match.arg(which)
    # which = "pdot"; session = "2"; CI = FALSE; contour = TRUE; centered = TRUE

    ##################################################
    ## mask and traps

    if(which == "density"){
        # use regiontraps and regular regionmask
        traps = traps_rbind(traps(fit$capthist))
        mask  = make_regular_regionmask(fit$mask, fit$capthist)
    }
    if(which == "pdot"){
        # use sessiontraps and sessionmask
        traps = traps(fit$capthist)[[session]]
        mask  = fit$mask[[session]]
    }
    buffer = mask_buffer(mask, traps)
    traps = MS(traps)
    mask  = MS(mask)
    session(traps) = session(mask) = session


    ##################################################
    ## delta method

    deltaargs = list(beta = coef(fit), fit = fit, session = session, mask = mask, traps = traps, which = which)
    if(CI){
        deltaargs$f = fitted_surface_values
        deltaargs$vcov = vcov(fit)
        delta = do.call(delta_method, deltaargs)
    }else{
        # delta = list(est = do.call(fitted_pdot_values, deltaargs))
        delta = list(est = do.call(fitted_surface_values, deltaargs))
    }

    ##################################################
    ## plot

    plotargs = list(...) # plotargs = list()
    plotargs = c(mask_image(mask[[session]], delta$est, plot = FALSE), plotargs)
    legend.mar = plotargs$legend.mar
    plotargs$legend.mar = NULL
    plotargs = plotargs[!sapply(plotargs, is.null)]
    if(is.null(plotargs$add) || !plotargs$add){
        if(is.null(plotargs$main)) plotargs$main = switch(
            which,
            "pdot"    = "Detection surface",
            "density" = "Density surface"
        )
        if(is.null(plotargs$xlab)) plotargs$xlab = ""
        if(is.null(plotargs$ylab)) plotargs$ylab = ""
        if(is.null(plotargs$axes)) plotargs$axes = TRUE
        if(is.null(plotargs$xaxs)) plotargs$xaxs = "i"
        if(is.null(plotargs$yaxs)) plotargs$yaxs = "i"
        if(is.null(plotargs$asp))  plotargs$asp  = 1
        if(is.null(plotargs$bty))  plotargs$bty  = "n"
    }
    if(is.null(plotargs$nlevel)) plotargs$nlevel = 25
    if(is.null(plotargs$col))    plotargs$col    = heat.colors(plotargs$nlevel)
    if(is.null(plotargs$ylim))   plotargs$zlim   = switch(
        which,
        "pdot"    = c(0,1),
        "density" = range(delta)
    )
    nlevel = plotargs$nlevel
    plotargs$nlevel = NULL
    axes = plotargs$axes
    if(centered && plotargs$axes) plotargs$axes = FALSE
    # image
    do.call(image, plotargs)
    if(centered && axes){
        tick.length = diff(axTicks(1)[1:2])
        for(i in 1:2){ # i=1
            cent = mean(traps[[1]][,i])
            at = sort(unique(c(
                seq(cent, cent - buffer, by = -tick.length),
                seq(cent, cent + buffer, by = tick.length)
            )))
            axis(i, at, as.character(at - cent))
        }
    }
    # save usr and mfg (image.plot changes them)
    # usr = par()$usr
    # mfg = par()$mfg
    # traps
    plot_traps(traps, add = TRUE, cex = 1)
    # contour and legend
    if(abs(diff(range(plotargs$zlim))) > 0){
        # contour
        if(contour) contour(plotargs$x, plotargs$y, plotargs$z, add = TRUE)
        # legend
        plotargs$nlevel = nlevel
        plotargs$graphics.reset = TRUE
        plotargs$legend.only = TRUE
        plotargs$legend.mar = legend.mar
        plotargs$breaks = seq(plotargs$zlim[1], plotargs$zlim[2], length = nlevel + 1)
        do.call(fields::image.plot, plotargs)
    }
    # par(usr = usr, mfg = mfg)
    invisible()
}

## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##

# @title TODO
# @description TODO
# @param x TODO
# @param add TODO
# @param pch TODO
# @param cex TODO
# @param col TODO
# @param ... TODO
# @author Darren Kidney \email{darrenkidney@@googlemail.com}
# @export
plot_traps = function(x, session = NULL, buffer = 1000, ...){
    # x = traps(capthist); session = NULL
    if(!inherits(x, c("capthist", "traps")))
        stop("requires a capthist or traps object", call. = FALSE)
    if(inherits(x, "capthist"))
        x = traps(x)
    if(!ms(x)){
        x = list(x)
        sessions = 1
    }else{
        sessions = if(is.null(session)){
            session(x)
        }else{
            if(is.numeric(session)){
                session(x)[session]
            }else{
                session
            }
        }
        x = x[sessions]
    }
    args = list(...) # args = list(add = TRUE)
    if(is.null(args$add))  args$add  = FALSE
    if(is.null(args$pch))  args$pch  = 15
    if(is.null(args$cex))  args$cex  = 0.5
    if(is.null(args$asp))  args$asp  = 1
    if(is.null(args$type)) args$type = "p"
    type = args$type
    add  = args$add
    args$add = NULL
    if(!add){
        bbox = apply(do.call(rbind, lapply(x, as.data.frame)), 2, range)
        args$x = bbox
        args$type = "n"
        do.call(plot, args)
        # plot(bbox, ...)
    }
    if(type != "n"){
        args$type = NULL
        args$asp = NULL
        for(i in sessions){ # i = sessions[1] ; i
            args$x = as.data.frame(x[[i]])
            do.call(points, args)
            # points(as.data.frame(x[[i]]), pch = pch, cex = cex, col = col)
        }
    }
    invisible()
}

## -------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------- ##
