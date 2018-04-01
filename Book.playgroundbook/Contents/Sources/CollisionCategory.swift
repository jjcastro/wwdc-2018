

public enum CollisionCategory: Int {
    case bottom = 0b00001
    case cube   = 0b00010
    case plane  = 0b00100
    
    // Tejo
    case bola =  0b01000
    case mecha = 0b10000
    
    case everything = 0b11110
}
