// AnimalSpeedComparison.swift
// SpeedLabJr
//
// Compares a sprint speed (m/s) to a curated list of animals
// and returns a fun, age-appropriate celebration message.

import Foundation

struct AnimalSpeedComparison {

    // MARK: - Animal catalogue (sorted ascending by speed)

    struct Animal: Identifiable {
        let id = UUID()
        let name: String
        let emoji: String
        let speedMps: Double      // metres per second
        let funFact: String       // shown in the card
    }

    static let animals: [Animal] = [
        Animal(name: "Garden Snail",   emoji: "🐌", speedMps: 0.013,
               funFact: "A snail takes about 14 hours to travel one mile."),
        Animal(name: "Tortoise",       emoji: "🐢", speedMps: 0.13,
               funFact: "Tortoises can live over 100 years — they're in no rush!"),
        Animal(name: "Chicken",        emoji: "🐓", speedMps: 1.4,
               funFact: "Chickens can sprint but can only fly a few feet."),
        Animal(name: "Penguin",        emoji: "🐧", speedMps: 1.8,
               funFact: "Penguins are faster underwater — up to 7 m/s swimming!"),
        Animal(name: "Duck",           emoji: "🦆", speedMps: 2.5,
               funFact: "Ducks are faster in the air than on the ground."),
        Animal(name: "Sheep",          emoji: "🐑", speedMps: 4.0,
               funFact: "A startled sheep can reach 25 km/h for short bursts."),
        Animal(name: "Squirrel",       emoji: "🐿️", speedMps: 4.5,
               funFact: "Squirrels can change direction instantly to escape predators."),
        Animal(name: "Rabbit",         emoji: "🐇", speedMps: 5.6,
               funFact: "Rabbits zig-zag at full speed — nearly impossible to catch!"),
        Animal(name: "Fox",            emoji: "🦊", speedMps: 6.4,
               funFact: "Foxes are clever and can sustain speed for long distances."),
        Animal(name: "House Cat",      emoji: "🐱", speedMps: 6.7,
               funFact: "Cats accelerate from 0 to top speed in just a few strides."),
        Animal(name: "Dog",            emoji: "🐕", speedMps: 7.6,
               funFact: "The average dog runs at 30 km/h — your furry rival!"),
        Animal(name: "White-tailed Deer", emoji: "🦌", speedMps: 8.9,
               funFact: "Deer can leap 3 metres high and 9 metres in a single bound."),
        Animal(name: "Greyhound",      emoji: "🏁", speedMps: 10.0,
               funFact: "Greyhounds are the fastest dog breed, reaching 72 km/h!"),
        Animal(name: "Horse",          emoji: "🐎", speedMps: 13.4,
               funFact: "Thoroughbred racehorses can sustain 60 km/h for a full mile."),
        Animal(name: "Cheetah",        emoji: "🐆", speedMps: 31.3,
               funFact: "The cheetah is the fastest land animal — 0 to 100 km/h in 3 seconds!"),
    ]

    // MARK: - Comparison logic

    /// Returns the animal whose speed is closest to (and ideally just above) the given speed,
    /// so the message is motivating rather than deflating.
    static func match(speedMps: Double) -> Animal {
        // Find the first animal that's faster than the user's speed
        if let faster = animals.first(where: { $0.speedMps > speedMps }) {
            return faster
        }
        // If they're faster than every animal (unlikely!), return cheetah
        return animals.last!
    }

    // MARK: - Message builder

    static func celebrationMessage(distanceMeters: Int, timeSeconds: Int) -> CelebrationResult? {
        guard timeSeconds > 0, distanceMeters > 0 else { return nil }
        let speedMps   = Double(distanceMeters) / Double(timeSeconds)
        let speedKmh   = speedMps * 3.6
        let animal     = match(speedMps: speedMps)

        let messages = [
            "You just ran as fast as a \(animal.name)! \(animal.emoji)",
            "At that speed you could keep up with a \(animal.name)! \(animal.emoji)",
            "That's \(animal.name) territory right there! \(animal.emoji)",
            "You're running \(animal.name) speeds! \(animal.emoji)",
        ]
        let message = messages[abs(distanceMeters + timeSeconds) % messages.count]

        return CelebrationResult(
            animal: animal,
            headline: message,
            speedKmh: speedKmh,
            funFact: animal.funFact
        )
    }

    struct CelebrationResult {
        let animal: Animal
        let headline: String
        let speedKmh: Double
        let funFact: String
    }
}
