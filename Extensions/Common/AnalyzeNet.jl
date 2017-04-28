using MXNet
using Econometrics.prettyprint
using PyPlot
# this script makes predictions, gets RMSEs, and plots the figure
function AnalyzeNet(savefile, data, trainsize, noutputs; title="", params="", doplot=false)
    Y = data[trainsize+1:end,1:noutputs]
    X = data[trainsize+1:end,noutputs+1:end]'
    model = mx.load_checkpoint(savefile, 20, mx.FeedForward) # load trained model
    # obtain predictions
    provider = mx.ArrayDataProvider(:data => X)
    fit = mx.predict(model, provider)
    fit = fit'
    # compute RMSE
    error = Y - fit
    bias = mean(error,1)
    mse = mean(error.^2,1)
    rmse = sqrt(mse)
    rsq = 1.0 .- mse./mean((Y .- mean(Y,1)).^2,1)
    names = ["bias","rmse","mse","R2"]
    println()
    println("________________________________________")
    println("Neural net indirect inference results")
    if title != "" println(title) end
    if params != ""
        prettyprint([bias' rmse' mse' rsq'], names, params)
    else
        prettyprint([bias' rmse' mse' rsq'], names)
    end     
    println("________________________________________")
    if doplot
        # get the first layer parameters for influence analysis
        model = mx.load_checkpoint(savefile, 20) # load trained model
        beta = copy(model[2][:fullyconnected0_weight])
        z = maximum(abs(beta),2);
        cax3 = matshow(z', interpolation="nearest")
        colorbar(cax3)
        ninputs = size(z,1)
        xlabels = [string(i) for i=1:ninputs]
        xticks(0:ninputs-1, xlabels)
        show()
        println("") # stop PyPlot screen spam
    end
    return fit
end

