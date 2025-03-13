//
//  MotivationView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/27/25.
//
import SwiftUI

struct MotivationView: View {
    @State private var currentQuote: String = getRandomMotivationalQuote()
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // App title
                Text("Daily Motivation")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                Spacer()
                
                // Quote display
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Text(currentQuote)
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .foregroundColor(.black.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(30)
                        .opacity(isAnimating ? 1 : 0)
                        .rotation3DEffect(
                            Angle(degrees: isAnimating ? 0 : 90),
                            axis: (x: 0.0, y: 1.0, z: 0.0)
                        )
                }
                .frame(height: 300)
                .padding(.horizontal, 25)
                
                Spacer()
                
                // Button to get a new quote
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isAnimating = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        currentQuote = getRandomMotivationalQuote()
                        
                        withAnimation(.easeIn(duration: 0.3)) {
                            isAnimating = true
                        }
                    }
                }) {
                    Text("New Quote")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                        .background(
                            Capsule()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
}

// Array of motivational quotes
let motivationalQuotes = [
    // Classic motivational quotes
    "The only way to do great work is to love what you do. - Steve Jobs",
    "Believe you can and you're halfway there. - Theodore Roosevelt",
    "It does not matter how slowly you go as long as you do not stop. - Confucius",
    "Success is not final, failure is not fatal: It is the courage to continue that counts. - Winston Churchill",
    "Don't watch the clock; do what it does. Keep going. - Sam Levenson",
    
    // Fitness-focused quotes
    "The hardest lift of all is lifting your butt off the couch. - Unknown",
    "Your body can stand almost anything. It's your mind that you have to convince. - Unknown",
    "Someone busier than you is working out right now. - Unknown",
    "Sweat is just fat crying. - Unknown",
    "The only bad workout is the one that didn't happen. - Unknown",
    
    // Short motivational phrases
    "Make it happen.",
    "Push your limits.",
    "No excuses.",
    "One more rep.",
    "Progress, not perfection.",
    
    // Mindset quotes
    "Whether you think you can or you think you can't, you're right. - Henry Ford",
    "The difference between the impossible and the possible lies in a person's determination. - Tommy Lasorda",
    "The pain you feel today will be the strength you feel tomorrow. - Unknown",
    "If it doesn't challenge you, it doesn't change you. - Fred DeVito",
    "Fall seven times, stand up eight. - Japanese Proverb",
    
    // Achievement quotes
    "The expert in anything was once a beginner. - Helen Hayes",
    "A year from now you may wish you had started today. - Karen Lamb",
    "The only place where success comes before work is in the dictionary. - Vidal Sassoon",
    "Your only limit is you. - Unknown",
    "Success is walking from failure to failure with no loss of enthusiasm. - Winston Churchill",
    
    // Perseverance quotes
    "Strength does not come from physical capacity. It comes from an indomitable will. - Mahatma Gandhi",
    "The body achieves what the mind believes. - Unknown",
    "Don't stop when you're tired. Stop when you're done. - Unknown",
    "Motivation is what gets you started. Habit is what keeps you going. - Jim Ryun",
    "You don't have to be great to start, but you have to start to be great. - Zig Ziglar",
    
    // Transformation quotes
    "Change your body, change your mind, change your life. - Unknown",
    "Strive for progress, not perfection. - Unknown",
    "Your health is an investment, not an expense. - Unknown",
    "Take care of your body. It's the only place you have to live. - Jim Rohn",
    "The only bad workout is the one that didn't happen. - Unknown",
    
    // Challenge quotes
    "The harder you work for something, the greater you'll feel when you achieve it. - Unknown",
    "If it doesn't challenge you, it won't change you. - Fred DeVito",
    "Challenges are what make life interesting and overcoming them is what makes life meaningful. - Joshua J. Marine",
    "Do something today that your future self will thank you for. - Unknown",
    "Your biggest challenge isn't someone else. It's the ache in your lungs and the burning in your legs, and the voice inside you that yells 'CAN'T', but you don't listen. - Unknown",
    
    // Goal-oriented quotes
    "A goal without a plan is just a wish. - Antoine de Saint-Exupéry",
    "Set goals. Smash them. Repeat. - Unknown",
    "Dream big, start small. - Unknown",
    "Focus on your goal. Don't look in any direction but ahead. - Unknown",
    "Small daily improvements are the key to staggering long-term results. - Unknown",
    
    // Mental toughness quotes
    "Pain is temporary. Quitting lasts forever. - Lance Armstrong",
    "What hurts today makes you stronger tomorrow. - Unknown",
    "When you feel like quitting, think about why you started. - Unknown",
    "Don't wish it were easier. Wish you were better. - Jim Rohn",
    "Mental toughness is doing the right thing for the team when it's not the best thing for you. - Bill Belichick",
    
    // Additions
    "The best way to predict the future is to create it. - Abraham Lincoln",
    "Every accomplishment starts with the decision to try. - John F. Kennedy",
    "Success is not in what you have, but who you are. - Bo Bennett",
    "The only limit to our realization of tomorrow is our doubts of today. - Franklin D. Roosevelt",
    "If you want to lift yourself up, lift up someone else. - Booker T. Washington",
    "The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt",
    "Happiness is not something ready-made. It comes from your own actions. - Dalai Lama",
    "In the middle of difficulty lies opportunity. - Albert Einstein",
    "The journey of a thousand miles begins with one step. - Lao Tzu",
    "Never let the fear of striking out keep you from playing the game. - Babe Ruth",
    "Strive not to be a success, but rather to be of value. - Albert Einstein",
    "The two most important days in your life are the day you are born and the day you find out why. - Mark Twain",
    "Life is what happens when you're busy making other plans. - John Lennon",
    "It does not matter how slowly you go as long as you do not stop. - Confucius",
    "When everything seems to be going against you, remember that the airplane takes off against the wind, not with it. - Henry Ford",
    "You can't use up creativity. The more you use, the more you have. - Maya Angelou",
    "Don't count the days, make the days count. - Muhammad Ali",
    "The best time to plant a tree was 20 years ago. The second best time is now. - Chinese Proverb",
    "The mind is everything. What you think you become. - Buddha",
    "An unexamined life is not worth living. - Socrates",
    "Be yourself; everyone else is already taken. - Oscar Wilde",
    "To succeed in life, you need two things: ignorance and confidence. - Mark Twain",
    "Believe you can and you're halfway there. - Theodore Roosevelt",
    "Challenges are what make life interesting. Overcoming them is what makes life meaningful. - Joshua J. Marine",
    "The only place where success comes before work is in the dictionary. - Vidal Sassoon",
    "If you can dream it, you can achieve it. - Zig Ziglar",
    "Your time is limited, don't waste it living someone else's life. - Steve Jobs",
    "If you tell the truth, you don't have to remember anything. - Mark Twain",
    "The purpose of our lives is to be happy. - Dalai Lama",
    "If life were predictable it would cease to be life and be without flavor. - Eleanor Roosevelt",
    "You only live once, but if you do it right, once is enough. - Mae West",
    "Success is not how high you have climbed, but how you make a positive difference to the world. - Roy T. Bennett",
    "Everything you can imagine is real. - Pablo Picasso",
    "Life isn't about finding yourself. Life is about creating yourself. - George Bernard Shaw",
    "The way to get started is to quit talking and begin doing. - Walt Disney",
    "The secret of change is to focus all of your energy, not on fighting the old, but on building the new. - Socrates",
    "The greatest glory in living lies not in never falling, but in rising every time we fall. - Nelson Mandela",
    "You must be the change you wish to see in the world. - Mahatma Gandhi",
    "Spread love everywhere you go. Let no one ever come to you without leaving happier. - Mother Teresa",
    "Always remember that you are absolutely unique. Just like everyone else. - Margaret Mead",
    "Don't judge each day by the harvest you reap but by the seeds that you plant. - Robert Louis Stevenson",
    "The future belongs to those who prepare for it today. - Malcolm X",
    "You will face many defeats in life, but never let yourself be defeated. - Maya Angelou",
    "Life is never fair, and perhaps it is a good thing for most of us that it is not. - Oscar Wilde",
    "In three words I can sum up everything I've learned about life: it goes on. - Robert Frost",
    "Courage is resistance to fear, mastery of fear, not absence of fear. - Mark Twain",
    "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. - Chantal Sutherland",
    "What you get by achieving your goals is not as important as what you become by achieving your goals. - Zig Ziglar",
    "Whatever the mind can conceive and believe, it can achieve. - Napoleon Hill",
    "We may encounter many defeats but we must not be defeated. - Maya Angelou",
    "The question isn't who is going to let me; it's who is going to stop me. - Ayn Rand"]

// Function to get a random quote
func getRandomMotivationalQuote() -> String {
    let randomIndex = Int.random(in: 0..<motivationalQuotes.count)
    return motivationalQuotes[randomIndex]
}

// Function to get multiple random quotes without repetition
func getMultipleRandomQuotes(count: Int) -> [String] {
    var quotes = motivationalQuotes
    var selectedQuotes: [String] = []
    
    // Make sure we don't request more quotes than available
    let requestCount = min(count, quotes.count)
    
    for _ in 0..<requestCount {
        let randomIndex = Int.random(in: 0..<quotes.count)
        selectedQuotes.append(quotes[randomIndex])
        quotes.remove(at: randomIndex)
    }
    
    return selectedQuotes
}

struct MotivationView_Previews: PreviewProvider {
    static var previews: some View {
        MotivationView()
    }
}
