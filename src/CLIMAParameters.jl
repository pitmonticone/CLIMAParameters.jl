module CLIMAParameters

using TOML
using DocStringExtensions

export AbstractParameterSet
export AbstractEarthParameterSet

export AbstractParamDict
export ParamDict, AliasParamDict

export float_type,
    get_parameter_values!,
    get_parameter_values,
    write_log_file,
    log_parameter_information,
    create_parameter_struct

"""
    AbstractParameterSet

The top-level super-type parameter set.
"""
abstract type AbstractParameterSet end

"""
    AbstractEarthParameterSet <: AbstractParameterSet

An earth parameter set, specific to planet Earth.
"""
abstract type AbstractEarthParameterSet <: AbstractParameterSet end

include("file_parsing.jl")

end # module
