import matplotlib.pyplot as plt
import itertools
from pathlib import Path

# Output directory
OUTPUT_DIR = Path("python-made-buttons")
OUTPUT_DIR.mkdir(exist_ok=True)

# Buttons colors
COLOR_MAP = {
    "close": ("#e67172", "#6272a4"),
    "maximize": ("#8ec772", "#6272a4"),
    "minimize": ("#d9ba73", "#6272a4"),
    "restore": ("#8ec772", "#6272a4"),
}

dpi = 5
pixels = 22

def make_figure(dpi=5, pixels=22):
    fig_size = pixels / dpi  
    fig, ax = plt.subplots(figsize=(fig_size, fig_size), dpi=dpi)
    ax.set_aspect('equal')
    ax.set_xlim(-0.5, 0.5)
    ax.set_ylim(-0.5, 0.5)
    ax.axis('off')
    return ax

class GtkButtons:
    def __init__(self, action, state, hover, theme='dark', img_format='svg', scaled=True, dpi=2, pixels=22):
        self.action = action
        self.state = state
        self.hover = hover
        self.theme = theme
        self.format = img_format
        self.scaled = scaled
        self.pixels = pixels * 2 if scaled else pixels
        self.dpi = dpi
        self.artifacts = self.define_artifacts()

    def define_artifacts(self):
        return {
            "close": [-0.12, 0.12],
            "maximize": {
                "top": ((-0.1, 0.2, 0.2, -0.1), (0.2, 0.2, -0.1, 0.2)),
                "low": ((-0.2, -0.2, 0.1, -0.2), (0.1, -0.2, -0.2, 0.1)),
            },
            "restore": {
                "top": ((0.02, 0.02, 0.28, 0.02), (0.28, 0.02, 0.02, 0.28)),
                "low": ((-0.28, -0.02, -0.02, -0.28), (-0.02, -0.28, -0.02, -0.02)),
            }
        }

    def draw_circle(self, ax, center=(0, 0), radius=0.4, color='r'):
        ax.add_artist(plt.Circle(center, radius, color=color))

    def draw_fill(self, ax):
        lw = 60 if self.scaled else 30
        if self.action == 'close':
            
            ax.plot(self.artifacts["close"], self.artifacts["close"][::-1], c='k', lw=lw)
            ax.plot(self.artifacts["close"], self.artifacts["close"], c='k', lw=lw)
            
        elif self.action == 'maximize':
            ax.fill(self.artifacts["maximize"]["low"][0], self.artifacts["maximize"]["low"][1], color='k')
            ax.fill(self.artifacts["maximize"]["top"][0], self.artifacts["maximize"]["top"][1], color='k')
            
        elif self.action == 'minimize':
            ax.plot((-0.15, 0.15), (0, 0), c='k', lw=lw)
            
        elif self.action == 'restore':
            ax.fill_between(self.artifacts["restore"]["top"][0], self.artifacts["restore"]["top"][1], color='k')
            ax.fill_between(self.artifacts["restore"]["low"][0], self.artifacts["restore"]["low"][1], color='k')

    def decide_color_and_action(self, button_color):
        
        ax = make_figure(dpi=self.dpi, pixels=self.pixels)
        
        self.draw_circle(ax, color=button_color)
        
        if self.state == "-active" or self.hover == '-hover':
            self.draw_fill(ax)

        suffix = "@2" if self.scaled else ""
        button_name = f"{OUTPUT_DIR}/titlebutton-{self.action}{self.state}{self.hover}-{self.theme}{suffix}.{self.format}"    

        plt.savefig(button_name, format=self.format, pad_inches=0, transparent=True, bbox_inches='tight')
        plt.close()

    def draw_button(self):
        button_color = COLOR_MAP[self.action][1 if self.state == "-backdrop" else 0]
        self.decide_color_and_action(button_color)

# Generate all possible combinations
action_buttons = ['close', 'maximize', 'minimize', 'restore']
state_values   = ["", "-active", "-backdrop"]
hover_values   = ["", "-hover"]
scale_values   = [True, False]
#format_values  = ['png', 'svg']

for action, state, hover, scale, in itertools.product(action_buttons, state_values, hover_values, scale_values):
    if state == "-active" and hover == "-hover":
        continue
    GtkButtons(action, state, hover, theme='dark', img_format='png', scaled=scale, dpi=dpi, pixels=pixels).draw_button()
