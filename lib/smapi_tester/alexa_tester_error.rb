AlexaTesterError      = Class.new(StandardError)

AlexaTesterError::SkillSimulationError  = Class.new(AlexaTesterError)
AlexaTesterError::InvalidAuthToken      = Class.new(AlexaTesterError)
AlexaTesterError::SimulationInProgress  = Class.new(AlexaTesterError)