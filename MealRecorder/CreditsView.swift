//
//  CreditsView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 8.10.2022.
//

import SwiftUI

struct CreditsView : View {
    var body: some View{
        ScrollView{
            VStack{
                Text("Credits")
                    .font(.largeTitle)
                    .bold()
                    .padding(.all)
                Link("AlertKit By Rebeloper", destination: URL(string: "https://github.com/rebeloper/AlertKit")!)
                    .tint(Color.blue)
                Text("THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.")
                    .padding(.all)
                    .font(.footnote)
                Link("Food Image By BomSymbols", destination: URL(string: "https://www.iconfinder.com/korawan_m")!)
                    .tint(Color.blue)
                    .padding(.all)
            }
        }
    }
}

struct CreditsView_Previews : PreviewProvider{
    static var previews: some View{
        CreditsView()
    }
}
