<template>
  <div class="bf6-layout">
    <!-- Rotating Background Video/GIF Container -->
    <div class="bf6-background-container">
      <div
        v-for="(clip, index) in backgroundClips"
        :key="index"
        class="bf6-background-clip"
        :class="{ active: currentClip === index }"
      >
        <!-- Use video element for MP4 files -->
        <video
          v-if="clip.endsWith('.mp4') || clip.endsWith('.webm')"
          :src="clip"
          autoplay
          muted
          loop
          playsinline
          class="bf6-bg-video"
        ></video>
        <!-- Use img element for GIF files -->
        <img
          v-else
          :src="clip"
          class="bf6-bg-image"
          alt="Battlefield 6 Gameplay"
        />
      </div>
      <!-- Dark overlay to ensure text readability -->
      <div class="bf6-background-overlay"></div>
    </div>

    <!-- VitePress Default Layout -->
    <DefaultTheme.Layout />
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import DefaultTheme from 'vitepress/theme'

// List of background clips (video files from YouTube)
const backgroundClips = ref([
  '/bg/bg-clip-1.mp4',
  '/bg/bg-clip-2.mp4',
  '/bg/bg-clip-3.mp4',
  '/bg/bg-clip-4.mp4'
  // Note: bg-clip-5.mp4 is too small (262 bytes), skipping it
])

const currentClip = ref(0)
let rotationInterval = null

onMounted(() => {
  // Rotate background every 10 seconds
  rotationInterval = setInterval(() => {
    currentClip.value = (currentClip.value + 1) % backgroundClips.value.length
  }, 10000) // 10 seconds per clip
})

onUnmounted(() => {
  if (rotationInterval) {
    clearInterval(rotationInterval)
  }
})
</script>

<style scoped>
.bf6-layout {
  position: relative;
  min-height: 100vh;
}

.bf6-background-container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  z-index: -1;
  overflow: hidden;
}

.bf6-background-clip {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0;
  transition: opacity 2s ease-in-out;
}

.bf6-background-clip.active {
  opacity: 1;
}

.bf6-bg-video,
.bf6-bg-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: blur(8px) brightness(0.2); /* Heavy blur and very dark for readability */
}

.bf6-background-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    180deg,
    rgba(0, 0, 0, 0.85) 0%,
    rgba(0, 0, 0, 0.75) 50%,
    rgba(0, 0, 0, 0.9) 100%
  );
  pointer-events: none;
}

/* Ensure content is above background */
:deep(.VPContent) {
  position: relative;
  z-index: 1;
}

/* Homepage hero adjustments */
:deep(.VPHome) {
  position: relative;
  z-index: 1;
}

/* Mobile optimization - disable background on small screens for performance */
@media (max-width: 768px) {
  .bf6-background-container {
    display: none;
  }
}
</style>
