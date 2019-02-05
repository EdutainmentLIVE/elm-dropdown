module Dropdown.Messages exposing (Msg(..))


type Msg item
    = NoOp
    | OnBlur
    | OnClear
    | OnClickPrompt
    | OnEsc
    | OnSelect item
