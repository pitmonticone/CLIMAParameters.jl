# import CLIMAParameters
import CLIMAParameters
const CP = CLIMAParameters


struct ParameterBox{FT}
    molmass_dryair::FT
    gas_constant::FT
    R_d::FT
    new_parameter::FT


end

function ParameterBox(param_struct::CP.ParamDict)


    aliases = ["molmass_dryair", "gas_constant","new_parameter"]

    (
        molmass_dryair,
        gas_constant,
        new_parameter,
    ) = CP.get_parameter_values!(
        param_struct,
        aliases,
        "ParameterBox",
    )

    #derived parameters
    R_d = gas_constant / molmass_dryair

    return ParameterBox{
        CP.float_type(param_struct),
    }(
        molmass_dryair,
        gas_constant,
        R_d,
        new_parameter,
    )
end


@testset "Example use case: parameter box" begin

    # [1.] read from file 
    toml_file = joinpath(@__DIR__, "toml", "parambox.toml")
    param_struct = CP.create_parameter_struct(
        toml_file,
        Float64,
        dict_type="alias",
    )

    # [2.] build
    param_set = ParameterBox(param_struct)

    # [3.] log & checks(with warning)
    mktempdir(@__DIR__) do path
        logfilepath = joinpath(path,"logfilepath.toml")
        @test_logs (:warn,) CP.log_parameter_information(param_struct,logfilepath)        
    end
    
    # [4.] use
    # from default
    @test param_set.molmass_dryair ≈ 0.02897
    # overridden default
    @test param_set.gas_constant ≈ 4.0
    # derived in constructor
    @test param_set.R_d ≈ param_set.gas_constant / param_set.molmass_dryair 
    # from toml
    @test param_set.new_parameter ≈ 19.99
    
end
rm(logfilepath1; force = true)
