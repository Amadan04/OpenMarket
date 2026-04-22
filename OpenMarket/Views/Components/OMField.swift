import SwiftUI

struct OMField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var trailing: String? = nil
    var leadingIcon: String? = nil
    @State private var showSecure = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(Color.omBgElevated)
                    .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.inter(12, weight: .medium))
                        .foregroundStyle(Color.omTextMuted)

                    HStack(spacing: Spacing.s) {
                        if let icon = leadingIcon {
                            Image(systemName: icon)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.omAccent)
                        }
                        if isSecure && !showSecure {
                            SecureField(placeholder, text: $text)
                                .font(.inter(16))
                                .foregroundStyle(Color.omText)
                        } else {
                            TextField(placeholder, text: $text)
                                .font(.inter(16))
                                .foregroundStyle(Color.omText)
                        }

                        if isSecure {
                            Button(showSecure ? "Hide" : "Show") { showSecure.toggle() }
                                .font(.inter(13, weight: .semibold))
                                .foregroundStyle(Color.omAccent)
                        } else if let t = trailing {
                            Text(t).font(.inter(13, weight: .semibold)).foregroundStyle(Color.omAccent)
                        }
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
            }
            .frame(minHeight: 58)
        }
    }
}

// Display-only variant (for read-only info rows)
struct OMFieldDisplay: View {
    let label: String
    let value: String
    var trailing: String? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.omBgElevated)
                .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.inter(12, weight: .medium)).foregroundStyle(Color.omTextMuted)
                HStack {
                    Text(value).font(.inter(16)).foregroundStyle(Color.omText)
                    Spacer()
                    if let t = trailing { Text(t).font(.inter(13, weight: .semibold)).foregroundStyle(Color.omAccent) }
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.m)
        }
        .frame(minHeight: 58)
    }
}
