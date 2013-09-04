EventManager = new EventEmitter()

Event =
  TrackAnalyzed : "Track Complete"

#   ECHONEST

class EchoNest
  RemixAPISettings:
    TRACK_ID :   'TRKCLIJ140E5FAB0E3'
    API      :   'SLU8WR6N1N06GTQNB'
    URL      :   'http://s3.amazonaws.com/easybakerstreetoven-en-us/remix_audio/02%20-%20Bowl.mp3' 

  remixer         : null
  context         : null
  player          : null
  status          : document.getElementById 'status-text'

  constructor:()->
    @status = document.getElementById 'status-text'
    @setupElements()
    @createContext()
    @createRemixer()

  setupElements : () ->

  createContext : () ->
    if webkitAudioContext? then @context = new webkitAudioContext() else @context = new AudioContext()

  createRemixer : () ->
    @remixer = createJRemixer @context, $, @RemixAPISettings.API
    @remixTrack()

  remixTrack    : () ->
    @remixer.remixTrackById @RemixAPISettings.TRACK_ID, @RemixAPISettings.URL, (track, percent) =>
      @track = track

      remix       = ( ) =>
        part = 'tatums'
        @remixed = track.analysis[part]
        EventManager.emitEvent Event.TrackAnalyzed, [@remixed]

      do remix if @track.status is 'ok'

#   GRAPHICS

class AudioPlayer
  context     : null

  constructor : () ->
    @checkWebAudioContext()
    @createContext()

  checkWebAudioContext: () ->
    if window.webkitAudioContext is undefined
      new Error("Sorry, this app needs advanced web audio. Your browser doesn't"
      + " support it. Try the latest version of Chrome")

  createContext : () ->
    if webkitAudioContext? then @context = new webkitAudioContext() else @context = new AudioContext()

  playSound     : (sound) ->
    @source = @context.createBufferSource()
    @source.buffer = sound
    @source.connect @context.destination
    @source.noteOn 0


class Graphics
  STEP_SIZE   : 1
  data        : null
  width       : window.innerWidth
  height      : window.innerHeight

  svg         : null
  minSize     : 1
  maxSize     : 3
  scaleFactor : 100

  audio       : null
  next        : null

  constructor : (@data, @audio) ->
    @createSVG()
    @createAudio()

  audioCallback : (e) =>
    @next = @currentAudioSample.next
    @currentAudioSample = @next

    circ = $($('#nodeHolder').children()[0]).children()[@currentElement + @STEP_SIZE]
    @currentElement += @STEP_SIZE

    d3.select(circ)
      .attr('r', 0)

    @audio.stop()
    @audio.play 0, @next

  createAudio : () ->
    @audio.addAfterPlayCallback(  @audioCallback )

  createSVG   : () ->
    @svg = d3.select("body").append("svg")
             .attr('id', 'nodeHolder')
             .attr("width", @width )
             .attr("height", @height )
             .append 'g'

    getSize = (d) =>
      size =  Math.min(@maxSize, Math.max( @minSize, d.confidence * @scaleFactor))
      return size

    scale = @width / parseInt(@data[0].track.audio_summary.duration)

    getX = (d) => 
      return d.start * scale

    yWave = 10
    yOffset = 400

    @svg.selectAll('g')
        .data( @data )
        .enter()
        .append('circle')
        .attr('cx', getX)
        .attr('cy', (d,i)=> return (Math.sin(i) * yWave) + yOffset)
        .attr('fill', 'black' )
        .attr('r', getSize)
        .on('mouseover', @onmouseover)

  onmouseover : (data, el, node) =>
    circle = d3.select d3.event.target
    circle.attr 'r', 0
    @currentElement = el
    @currentAudioSample = data
    @audio.stop()
    @audio.play 0, data


init = ()=>
  echo = new EchoNest()

  EventManager.addListener Event.TrackAnalyzed, (trackData)=>
    echo.status.innerHTML = ""

    gfx = new Graphics trackData, echo.remixer.getPlayer()


$(document).ready(=> 
  init()
)
